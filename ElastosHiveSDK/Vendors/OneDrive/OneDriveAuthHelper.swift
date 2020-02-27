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

@inline(__always) private func TAG() -> String { return "OneDriveAuthHelper" }

@objc(OneDriveAuthHelper)
internal class OneDriveAuthHelper: ConnectHelper {
    let clientIdKey: String = "client_id"
    let accessTokenKey: String = "access_token"
    let refreshTokenKey: String = "refresh_token"
    let expireAtKey: String = "expires_in"
    
    var clientId: String
    var scope: String
    var redirectUrl: String
    var token: AuthToken?
    let server = SimpleAuthServer.sharedInstance
    var connectState: Bool = false
    var persistent: Persistent
    
    init(_ clientId: String, _ scope: String, _ redirectUrl: String, _ persistentStorePath: String) {
        self.clientId = clientId
        self.scope = scope
        self.redirectUrl = redirectUrl
        self.persistent = AuthInfoStoreImpl(persistentStorePath)
    }

    override func connectAsync(authenticator: Authenticator? = nil) -> HivePromise<Void> {
        return connectAsync(authenticator: authenticator, handleBy: HiveCallback<Void>())
    }

    override func connectAsync(authenticator: Authenticator? = nil, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void> { resolver in
            self.do_login(authenticator!).done { _ in
                handleBy.didSucceed(Void())
                resolver.fulfill(Void())
            }.catch { error in
                handleBy.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    func disconnect() {
        return connectState = false
    }
    
    override func checkValid() -> HivePromise<Void> {
        return checkValid(handleBy: HiveCallback<Void>())
    }
    
    override func checkValid(handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void> { resolver in
            guard !isExpired() else {
                _ = refreshToken().done{ authToken in
                    resolver.fulfill(Void())
                    }.catch{ error in
                        resolver.reject(error)
                }
                return
            }
            resolver.fulfill(Void())
        }
    }
    
    private func do_login(_ authenticator: Authenticator) -> HivePromise<Void> {
        
        connectState = false
        tryRestoreToken()
        if token != nil {
            if !(token!.isExpired()) {
                connectState = true
                return HivePromise<Void>()
            }
            return refreshToken()
        }
        
        return HivePromise<Void> { resolver in
            self.acquireAuthCode(authenticator)
                .then { authCode -> HivePromise<Void>  in
                    return self.acquireAccessToken(authCode)
                }.done { _ in
                    self.connectState = true
                    Log.d(TAG(), "Login succeed")
                    resolver.fulfill(Void())
                }.catch { error in
                    self.connectState = false
                    resolver.reject(error)
            }
        }
    }
    
    private func tryRestoreToken() {
        let json = JSON(persistent.parseFrom())
        var refreshToken = ""
        var accessToken = ""
        var expiresAt = -1
        
        if (json[refreshTokenKey].stringValue != "") {
            refreshToken = json[refreshTokenKey].stringValue
        }
        if (json[accessTokenKey].stringValue != "") {
            accessToken = json[accessTokenKey].stringValue
        }
        if (json[expireAtKey].stringValue != "") {
            expiresAt = json[expireAtKey].intValue
        }
        if refreshToken != "" && accessToken != "" && expiresAt > 0 {
            self.token = AuthToken(refreshToken, accessToken, expiresAt)
        }
    }
    
    private func sotre(_ json: JSON) {
        let exTime = Int(Date().timeIntervalSince1970) + json[expireAtKey].intValue
        token = AuthToken(json[refreshTokenKey].stringValue, json[accessTokenKey].stringValue, exTime)
        let dict = [clientIdKey: clientId, refreshTokenKey: token!.refreshToken, accessTokenKey: token!.accessToken, expireAtKey: token!.expiredTime]
        persistent.upateContent(dict)
    }

    private func acquireAuthCode(_ authenticator: Authenticator) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            let startIndex: String.Index = redirectUrl.index(redirectUrl.startIndex, offsetBy: 17)
            let endIndex: String.Index =  redirectUrl.index(redirectUrl.startIndex, offsetBy: redirectUrl.count)
            let port = UInt16(redirectUrl[startIndex..<endIndex])
            let param = "client_id=\(clientId)&scope=\(scope)&response_type=code&redirect_uri=\(redirectUrl)"

            let url = OneDriveURL.acquireAuthCode(param)
            server.startRun(port!)
            _ = authenticator.requestAuthentication(url)
            server.getCode().done{ auth in
                Log.d(TAG(), "AuthCode succeed")
                resolver.fulfill(auth)
                }.catch{ error in
                    resolver.reject(error)
            }
        }
    }

    private func acquireAccessToken(_ authCode: String) -> HivePromise<Void> {
        return HivePromise<Void> { resolver in
            let params: Dictionary<String, Any> = [
                "client_id" : clientId,
                "code" : authCode,
                "grant_type" : GRANT_TYPE_GET_TOKEN,
                "redirect_uri" : redirectUrl
            ]
            let url = OneDriveURL.token()
            var urlRequest = URLRequest(url: URL(string: url)!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = params.queryString.data(using: String.Encoding.utf8)
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            Alamofire.request(urlRequest).responseJSON(completionHandler: { dataResponse in
                guard dataResponse.response?.statusCode == 200 else{
                    let error: HiveError = HiveError.failue(des: dataResponse.description())
                    resolver.reject(error)
                    return
                }
                Log.d(TAG(), "AccessToken succeed")
                let json: JSON =  JSON(dataResponse.result.value as Any)
                self.sotre(json)
                resolver.fulfill(Void())
            })
        }
    }

    private func refreshToken() -> HivePromise<Void> {
        return HivePromise<Void> {  resolver in
            let params: Dictionary<String, Any> = [
                "client_id" : clientId,
                "scope" : scope,
                "redirect_uri" : redirectUrl,
                "refresh_token": self.token!.refreshToken,
                "grant_type": GRANT_TYPE_REFRESH_TOKEN
            ]
            let url = OneDriveURL.token()
            var urlRequest = URLRequest(url: URL(string: url)!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = params.queryString.data(using: String.Encoding.utf8)
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            Alamofire.request(urlRequest).responseJSON(completionHandler: { dataResponse in
                guard dataResponse.response?.statusCode == 200 else{
                    let json = JSON(JSON(dataResponse.result.value as Any)["error"])
                    self.connectState = false
                    let error = HiveError.failue(des: json["message"].stringValue)
                    resolver.reject(error)
                    return
                }
                self.connectState = true
                Log.d(TAG(), "RefreshToken succeed")
                let json: JSON = JSON(dataResponse.result.value as Any)
                self.sotre(json)
                resolver.fulfill(Void())
            })
        }
    }
    
    private func isExpired() -> Bool {
        if (token == nil || token!.isExpired())
        {
            connectState = false
        }
        else {
            connectState = true
        }
        return !connectState
    }
}

