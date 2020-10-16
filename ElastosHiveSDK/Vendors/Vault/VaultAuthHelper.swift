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
    let clientIdKey: String = "client_id"
    let accessTokenKey: String = "access_token"
    let refreshTokenKey: String = "refresh_token"
    let expireInKey: String = "expires_in"
    let tokenType: String = "token_type"
    let expireAtKey: String = "expires_at"
    private var _clientId: String?
    private var _scope: String?
    private var _redirectUrl: String?
    var token: AuthToken?
    private let _server = SimpleAuthServer.sharedInstance
    private var _connectState: Bool = false
    private var _persistent: Persistent
    private var _nodeUrl: String
    private var _authToken: String?
    private var _clientSecret: String?

    private var _authenticationDIDDocument: DIDDocument?
    private var _authenticationHandler: Authenticator?

    public init(_ nodeUrl: String, _ storePath: String, _ authenticationDIDDocument: DIDDocument, _ handler: Authenticator?) {
        _authenticationDIDDocument = authenticationDIDDocument
        _authenticationHandler = handler
        _nodeUrl = nodeUrl
        _persistent = VaultAuthInfoStoreImpl(storePath)

        VaultURL.sharedInstance.resetVaultApi(baseUrl: _nodeUrl)
        // TODO:
        // reset auth api
    }

    public init(_ nodeUrl: String, _ storePath: String, clientId: String, _ clientSecret: String, _ redirectUrl: String, _ scope: String) {
        _clientId = clientId
        _scope = scope
        _redirectUrl = redirectUrl
        _nodeUrl = nodeUrl
        _clientSecret = clientSecret
        _persistent = VaultAuthInfoStoreImpl(storePath)

        VaultURL.sharedInstance.resetVaultApi(baseUrl: _nodeUrl)
        // TODO:
        // reset auth api
    }

    public override func checkValid() -> HivePromise<Void> {

        return checkValid(handleBy: HiveCallback<Void>())
    }

    public override func checkValid(handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void> { resolver in
            let globalQueue = DispatchQueue.global()
            globalQueue.async {
                do {
                    try self.doCheckExpired()
                    resolver.fulfill(Void())
                }
                catch {
                    resolver.reject(error)
                }
            }
        }
    }

    private func doCheckExpired() throws {
        _connectState = false
        tryRestoreToken()
        if token == nil || token!.isExpired() {
            try signIn(self._authenticationHandler)
        }
    }

    private func signIn(_ handler: Authenticator?) throws {

        let json = _authenticationDIDDocument!.toString()
        let data = json.data(using: .utf8)
        let json0 = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]

        let param = ["document": json0]
        let url = VaultURL.sharedInstance.signIn()
        var challenge = ""
        var erro = ""
        let header = ["Content-Type": "application/json;charset=UTF-8"]
        let semaphore: DispatchSemaphore! = DispatchSemaphore(value: 0)
        VaultApi.request(url: url, parameters: param as Parameters, headers: header)
            .done { re in
                challenge = re["challenge"].stringValue
                semaphore.signal()
        }.catch { err in
            print(err)
            erro = "121212"
            semaphore.signal()
        }
        semaphore.wait()
        guard erro == "" else {
            throw HiveError.failue(des: erro)
        }
        if handler != nil && self.verifyToken(challenge) {
            let semaphore: DispatchSemaphore! = DispatchSemaphore(value: 0)
            requestAuthToken(handler!, challenge).then { aToken -> HivePromise<JSON> in
                return self.nodeAuth(aToken)
            }.done { re in
                self.sotre(re)
                semaphore.signal()
            }.catch { error in
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    private func requestAuthToken(_ handler: Authenticator, _ challenge: String) -> HivePromise<String> {
        return handler.requestAuthentication(challenge)
    }

    private func verifyToken(_ jwtToken: String) -> Bool {
        do {
            let jwtParser = try JwtParserBuilder().build()
            _ = try jwtParser.parseClaimsJwt(jwtToken)
        } catch {
            return false
        }
        return true
    }

    private func syncGoogleDrive() -> HivePromise<JSON> {
        let token = JSON(_persistent.parseFrom())
        let param = ["token": token["access_token"].stringValue,
                     "refresh_token": token["refresh_token"].stringValue,
                     "token_uri": TOKEN_URI,
                     "client_id": _clientId!,
                     "client_secret": _clientSecret!,
                     "scopes": SCOPES,
                     "expiry": token["expires_at"].intValue] as [String : Any]
        VaultURL.sharedInstance.resetVaultApi(baseUrl: _nodeUrl)// test
        let url = VaultURL.sharedInstance.synchronization()

        return VaultApi.request(url: url, parameters: param)
    }

    private func tryRestoreToken() {
        let json = JSON(_persistent.parseFrom())
//        var refreshToken = ""
        var accessToken = ""
        var expiresAt = -1

        if (json[accessTokenKey].stringValue != "") {
            accessToken = json[accessTokenKey].stringValue
        }
        if (json[expireAtKey].stringValue != "") {
            expiresAt = json[expireAtKey].intValue
        }
        if accessToken != "" && expiresAt > 0 {
            self.token = AuthToken("", accessToken, expiresAt)
        }
    }

    private func sotre(_ json: JSON) {
        let exTime = Int(Date().timeIntervalSince1970) + json[expireInKey].intValue
        token = AuthToken("", json[accessTokenKey].stringValue, exTime)
        let dict = [accessTokenKey: token!.accessToken, expireAtKey: token!.expiredTime]
        _persistent.upateContent(dict)
    }

    private func initConnection() {
        VaultURL.sharedInstance.resetVaultApi(baseUrl: _nodeUrl)
    }

    private func nodeAuth(_ jwt: String) -> HivePromise<JSON> {
        VaultURL.sharedInstance.resetVaultApi(baseUrl: _nodeUrl)
        let url = VaultURL.sharedInstance.auth()
        let param = ["jwt": jwt]
       return VaultApi.nodeAuth(url: url, parameters: param)
    }
}
