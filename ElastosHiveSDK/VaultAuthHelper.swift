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

let lock = NSLock()
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
    var vaultUrl: VaultURL
    private var _connectState: Bool = false
    private var _persistent: Persistent
    private var _nodeUrl: String

    private var context: ApplicationContext
    private var authenticationAdapterImpl: AuthenticationAdapterImpl

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

    public init(_ context: ApplicationContext, _ ownerDid: String, _ nodeUrl: String, _ shim: AuthenticationAdapterImpl) {
        self.context = context
        self._ownerDid = ownerDid
        self._nodeUrl = nodeUrl
        self.authenticationAdapterImpl = shim
        self._persistent = VaultAuthInfoStoreImpl(ownerDid, nodeUrl, self.context.getLocalDataDir())
        self.vaultUrl = VaultURL(_nodeUrl)
    }
    
    public override func checkValid() -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            lock.lock()
            try doCheckExpired()
        }
    }

    private func doCheckExpired() throws {
        do {
            assert(!Thread.isMainThread)
            _connectState = false
            try tryRestoreToken()
            if token != nil && !(token!.isExpired()) {
                lock.unlock()
                return
            }
            try signIn()
            lock.unlock()
        }
        catch {
            lock.unlock()
            throw error
        }
    }

    func signIn() throws {
        let jsonstr = self.context.getAppInstanceDocument().description
        let data = jsonstr.data(using: .utf8)
        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
        let params = ["document": json as Any] as [String: Any]
        let url = vaultUrl.signIn()
        
        let response = AF.request(url,
                          method: .post,
                          parameters: params as Parameters,
                          encoding: JSONEncoding.default,
                          headers: HiveHeader.init(self).NormalHeaders()).responseJSON()
        let responseJson = try VaultApi.handlerJsonResponse(response)
        _ = try VaultApi.handlerJsonResponseCanRelogin(responseJson, tryAgain: 1)
        let challenge = responseJson["challenge"].stringValue
        guard challenge != "" else {
            throw HiveError.challengeIsNil(des: "Sign in failed")
        }
        try verifyToken(challenge)
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        var err: String = ""
        var authToken = ""
        authenticationAdapterImpl.authenticate(self.context, challenge).done { aToken in
            authToken = aToken
            semaphore.signal()
        }.catch { error in
            semaphore.signal()
            err = error.localizedDescription
        }
        semaphore.wait()
        guard err == "" else {
            throw HiveError.accessAuthToken(des: err)
        }
        try nodeAuth(authToken)
    }
    
    private func verifyToken(_ jwtToken: String) throws {
        let jwtParser = try JwtParserBuilder().build()
        let claims = try jwtParser.parseClaimsJwt(jwtToken).claims
        let exp = claims.getExpiration()
        let aud = claims.getAudience()
        let did = self.context.getAppInstanceDocument().subject.description
        if aud == nil || did != aud! {
            throw HiveError.jwtVerify(des: "authenticationDIDDocument's subject is not equal to audience")
        }
        let currentTime = Date()
        guard let _ = exp else {
            return
        }
        if currentTime > exp! {
            throw HiveError.jwtVerify(des: "challenge token is expiration.")
        }
    }

    private func tryRestoreToken() throws {
        let json = try JSON(_persistent.parseFrom())
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
        var userDid: String?
        var appDid: String?
        if let propos = c.get(key:"props") as? String {
            if let dict = try? JSONSerialization.jsonObject(with: propos.data(using: .utf8)!, options: .mutableContainers)  {
                let json = JSON(dict)
                userDid = json["userDid"].stringValue
                appDid = json["appDid"].stringValue
            }
        }
        if let _ = userDid {
            setUserDid(userDid!)
        }
        if let _ = appDid {
            setAppId(appDid! )
        }
        
        if let appInstanceDid = c.getAudience() {
            setAppInstanceDid(appInstanceDid)
        }
        
        let expiresTime: String = Date.convertToUTCStringFromDate(exp!)
        token = AuthToken("", json[ACCESS_TOKEN_KEY].stringValue, expiresTime)
        let json = [ACCESS_TOKEN_KEY: token!.accessToken,
                    EXPIRES_AT_KEY: token!.expiredTime,
                    TOKEN_TYPE_KEY: "token",
                    USER_DID_KEY: _userDid,
                    APP_ID_KEY: _appId,
                    APP_INSTANCE_DID_KEY: _appInstanceDid]
        try _persistent.upateContent(json as Dictionary<String, Any>)
    }
    
    private func nodeAuth(_ token: String) throws {
        let url = vaultUrl.auth()
        let params = ["jwt": token]
        let response = AF.request(url,
                            method: .post,
                            parameters: params,
                            encoding: JSONEncoding.default).responseJSON()
        let responseJson = try VaultApi.handlerJsonResponse(response)
        _ = try VaultApi.handlerJsonResponseCanRelogin(responseJson, tryAgain: 1)
        try self.sotre(responseJson)
    }
    
    func retryLogin() -> Promise<Bool> {
        return Promise<Bool> { resolver in
            try signIn()
            resolver.fulfill(true)
        }
    }
    
    public func removeToken() throws {
        try _persistent.deleteContent()
        self.token = nil
    }
}
