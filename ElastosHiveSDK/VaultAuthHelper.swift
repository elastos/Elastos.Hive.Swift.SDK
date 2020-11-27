/*
* Copyright (c) 2019 Elastos Foundation
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import Foundation

@inline(__always) private func TAG() -> String { return "VaultAuthHelper" }
public class VaultAuthHelper: ConnectHelper {
    let USER_DID_KEY: String = "user_did"
    let APP_ID_KEY: String = "app_id"
    let APP_INSTANCE_DID_KEY: String = "app_instance_did"

    let ACCESS_TOKEN_KEY: String = "access_token"
    let REFRESH_TOKEN_KEY: String = "refresh_token"
    let TOKEN_TYPE_KEY: String = "token_type"
    let EXPIRES_AT_KEY: String = "expires_at"
    private var _ownerDid: String?
    private var _userDid: String?
    private var _appId: String?
    private var _appInstanceDid: String?

    var token: AuthToken?
    private var _connectState: Bool = false
    private var _persistent: Persistent
    private var _nodeUrl: String

    private var _authenticationDIDDocument: DIDDocument?
    var _authenticationHandler: Authenticator?

    public var ownerDid: String? {
        return _ownerDid
    }

    public var userDid: String? {
        return _userDid
    }

    public func setUserDid(_ userDid: String) {
        _userDid = userDid
    }

    public var appId: String? {
        return _appId
    }

    public func setAppId(_ appId: String) {
        _appId = appId
    }

    public var appInstanceDid: String? {
        return _appInstanceDid
    }

    public func setAppInstanceDid(_ appInstanceDid: String) {
        _appInstanceDid = appInstanceDid
    }

    public init(_ ownerDid: String, _ nodeUrl: String, _ storePath: String, _ authenticationDIDDocument: DIDDocument, _ handler: Authenticator?) {
        PromiseKit.conf.Q = (map: HiveVaultQueue, return: HiveVaultQueue)
        _authenticationDIDDocument = authenticationDIDDocument
        _authenticationHandler = handler
        _ownerDid = ownerDid
        _nodeUrl = nodeUrl
        _persistent = VaultAuthInfoStoreImpl(ownerDid, nodeUrl, storePath)

        VaultURL.sharedInstance.resetVaultApi(baseUrl: _nodeUrl)
    }
    
    public override func checkValid() -> HivePromise<Void> {
        return doCheckExpired()
    }

    private func doCheckExpired() -> HivePromise<Void> {
        return HivePromise<Void> { resolver in
            
            _connectState = false
            tryRestoreToken()
            if !Thread.isMainThread {
                try signIn()
                resolver.fulfill(Void())
                return
            }
            DispatchQueue.global().async { [self] in
                do {
                    try signIn()
                    resolver.fulfill(Void())
                }
                catch {
                    resolver.reject(error)
                }
            }
        }
    }

    private func requestAuthToken(_ handler: Authenticator, _ challenge: String) -> HivePromise<String> {
        return handler.requestAuthentication(challenge)
    }

    private func verifyToken(_ jwtToken: String) throws {
        let jwtParser = try JwtParserBuilder().build()
        let claims = try jwtParser.parseClaimsJwt(jwtToken).claims
        let exp = claims.getExpiration()
        let aud = claims.getAudience()
        let did = _authenticationDIDDocument?.subject.description
        if did == nil || aud == nil || did! != aud! {
            throw HiveError.failure(des: "authenticationDIDDocument's subject is not equal to audience")
        }
        let currentTime = Date()
        guard let _ = exp else {
            return
        }
        if currentTime > exp! {
            throw HiveError.failure(des: "challenge token is expiration.")
        }
    }

    private func tryRestoreToken() {
        self.token = nil
        let json = JSON(_persistent.parseFrom())
        _userDid = json[USER_DID_KEY].stringValue
        _appId = json[APP_ID_KEY].stringValue
        _appInstanceDid = json[APP_INSTANCE_DID_KEY].stringValue

        var accessToken = ""
        var expiredTime = ""
        var refreshToken = ""
        if (json[ACCESS_TOKEN_KEY].stringValue != "") {
            accessToken = json[ACCESS_TOKEN_KEY].stringValue
        }
        if (json[EXPIRES_AT_KEY].stringValue != "") {
            expiredTime = json[EXPIRES_AT_KEY].stringValue
        }
        if (json[REFRESH_TOKEN_KEY].stringValue != "") {
            refreshToken = json[EXPIRES_AT_KEY].stringValue
        }
        if accessToken != "" && expiredTime != "" {
            self.token = AuthToken(refreshToken, accessToken, expiredTime)
        }
    }

    private func sotre(_ json: JSON) throws {
        let access_token = json[ACCESS_TOKEN_KEY].stringValue
        let jp = try JwtParserBuilder().build()
        let c = try jp.parseClaimsJwt(access_token).claims
        let exp = c.getExpiration()
        setUserDid(c.get(key: "userDid") as! String)
        setAppId(c.get(key:"appId") as! String)
        setAppInstanceDid(c.get(key:"appInstanceDid") as! String)
        let expiresTime: String = Date.convertToUTCStringFromDate(exp!)
        token = AuthToken("", json[ACCESS_TOKEN_KEY].stringValue, expiresTime)
        let json = [ACCESS_TOKEN_KEY: token!.accessToken,
                    EXPIRES_AT_KEY: token!.expiredTime,
                    TOKEN_TYPE_KEY: "token",
                    USER_DID_KEY: _userDid,
                    APP_ID_KEY: _appId,
                    APP_INSTANCE_DID_KEY: _appInstanceDid]
        _persistent.upateContent(json as Dictionary<String, Any>)
    }

    func signIn() throws {
        let jsonstr = _authenticationDIDDocument!.toString()
        let data = jsonstr.data(using: .utf8)
        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
        var params = ["document": json as Any] as [String: Any]
        var url = VaultURL.sharedInstance.signIn()
        let header = ["Content-Type": "application/json;charset=UTF-8"]
        
        var response = Alamofire.request(url,
                          method: .post,
                          parameters: params as Parameters,
                          encoding: JSONEncoding.default,
                          headers: header).responseJSON()
        var responseJson = try VaultApi.handlerJsonResponse(response)
        let challenge = responseJson["challenge"].stringValue
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        var err: String = ""
        var authToken = ""
        self.requestAuthToken(self._authenticationHandler!, challenge).done { aToken in
            authToken = aToken
            semaphore.signal()
        }.catch { error in
            semaphore.signal()
            err = error.localizedDescription
        }
        semaphore.wait()
        guard err == "" else {
            throw HiveError.getAuthToken(des: err)
        }
        
        url = VaultURL.sharedInstance.auth()
        params = ["jwt": authToken]
        response = Alamofire.request(url,
                            method: .post,
                            parameters: params,
                            encoding: JSONEncoding.default).responseJSON()
        responseJson = try VaultApi.handlerJsonResponse(response)
        try self.sotre(responseJson)
    }
    
    func retryLogin() -> HivePromise<Bool> {
        return HivePromise<Bool> { resolver in
            try signIn()
            resolver.fulfill(true)
        }
    }
    
    private func delete() {
        token = AuthToken("", "", "")
        let json = [ACCESS_TOKEN_KEY: token!.accessToken,
                    EXPIRES_AT_KEY: token!.expiredTime,
                    TOKEN_TYPE_KEY: "token",
                    USER_DID_KEY: "",
                    APP_ID_KEY: "",
                    APP_INSTANCE_DID_KEY: ""]
        _persistent.upateContent(json as Dictionary<String, Any>)
    }
}
