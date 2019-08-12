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
internal class OneDriveAuthHelper: AuthHelper {
    var token: AuthToken?
    let server = SimpleAuthServer.sharedInstance
    var authEntry: OAuthEntry

    init(_ authEntry: OAuthEntry) {
        self.authEntry = authEntry
    }

    override func loginAsync(_ authenticator: Authenticator) -> HivePromise<Void> {
        return loginAsync(authenticator, handleBy: HiveCallback<Void>())
    }

    override func loginAsync(_ authenticator: Authenticator, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        token = KeyChainStore.restoreToken(.oneDrive)
        guard token == nil else {
            return HivePromise<Void> { resolver in
                Log.d(TAG(), "OneDrive already logined")
                authEntry = KeyChainStore.restoreAuthEntry(.oneDrive)!
                handleBy.didSucceed(Void())
                resolver.fulfill(Void())
            }
        }

        return HivePromise<Void> { resolver in
            self.acquireAuthCode(authenticator)
                .then { authCode -> HivePromise<Void>  in
                    return self.acquireAccessToken(authCode)
                }.done { padding in
                    Log.d(TAG(), "Login succeed")
                    handleBy.didSucceed(padding)
                    resolver.fulfill(padding)
                }.catch { error in
                    Log.e(TAG(), "Login faild: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
    }

    override func logoutAsync() -> HivePromise<Void> {
        return logoutAsync(handleBy: HiveCallback<Void>())
    }

    override func logoutAsync(handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void> { resolver in
            let url: String = "\(OneDriveURL.AUTH)\(ONEDRIVE_SUB_Url.ONEDRIVE_LOGOUT.rawValue)?post_logout_redirect_uri=\(authEntry.redirectURL)"

            OneDriveAPIs.request(url: url,
                                       method: .get,
                                       parameters: nil,
                                       encoding: JSONEncoding.default,
                                       headers: nil,
                                       avalidCode: 200, self)
                .done { jsonData in
                    Log.d(TAG(), "Logout succeed")
                    self.token = nil
                    KeyChainStore.removeback(authEntry: self.authEntry, forDrive: .oneDrive)
                    handleBy.didSucceed(Void())
                    resolver.fulfill(Void())
                }
                .catch { error in
                    Log.e(TAG(), "Logout faild: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
    }

    private func acquireAuthCode(_ authenticator: Authenticator) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            let redirecturl: String = authEntry.redirectURL
            let startIndex: String.Index = redirecturl.index(redirecturl.startIndex, offsetBy: 17)
            let endIndex: String.Index =  redirecturl.index(redirecturl.startIndex, offsetBy: redirecturl.count)
            let port = UInt16(redirecturl[startIndex..<endIndex])
            let client_id: String = authEntry.clientId
            let scope: String = authEntry.scope
            let param = "client_id=\(client_id)&scope=\(scope)&response_type=code&redirect_uri=\(redirecturl)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

            let url = "\(OneDriveURL.AUTH)/\(ONEDRIVE_SUB_Url.ONEDRIVE_AUTHORIZE.rawValue)?\(param)"
            server.startRun(port!)
            _ = authenticator.requestAuthentication(url)
            server.getCode().done{ auth in
                Log.d(TAG(), "AuthCode succeed")
                resolver.fulfill(auth.authCode)
                }.catch{ error in
                    Log.e(TAG(), "AuthCode faild: \(HiveError.des(error as! HiveError))")
                    resolver.reject(error)
            }
        }
    }

    private func acquireAccessToken(_ authCode: String) -> HivePromise<Void> {
        return HivePromise<Void> { resolver in
            let params: Dictionary<String, Any> = [
                "client_id" : self.authEntry.clientId,
                "code" : authCode,
                "grant_type" : AUTHORIZATION_TYPE_CODE,
                "redirect_uri" : self.authEntry.redirectURL
            ]
            let url = "\(OneDriveURL.AUTH)\(ONEDRIVE_SUB_Url.ONEDRIVE_TOKEN.rawValue)"
            var urlRequest = URLRequest(url: URL(string: url)!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = params.queryString.data(using: String.Encoding.utf8)
            urlRequest.setValue(OneDriveHttpHeader.ContentTypeValue, forHTTPHeaderField: OneDriveHttpHeader.ContentType)
            Alamofire.request(urlRequest).responseJSON(completionHandler: { dataResponse in
                guard dataResponse.response?.statusCode == 200 else{
                    let error: HiveError = HiveError.failue(des: dataResponse.toString())
                    Log.e(TAG(), "AccessToken faild: \(HiveError.des(error))")
                    resolver.reject(error)
                    return
                }
                Log.d(TAG(), "AccessToken succeed")
                let jsonData: JSON =  JSON(dataResponse.result.value as Any)
                self.token = AuthToken()
                self.token?.accessToken = jsonData[KEYCHAIN_KEY.ACCESS_TOKEN.rawValue].stringValue
                self.token?.refreshToken = jsonData[KEYCHAIN_KEY.REFRESH_TOKEN.rawValue].stringValue
                self.token?.expiredIn = jsonData[KEYCHAIN_KEY.EXPIRES_IN.rawValue].int64Value
                self.token?.expiredTime = Timestamp.getTimeAfter(time: self.token!.expiredIn)
                KeyChainStore.writeback(self.token!, self.authEntry, .oneDrive)
                resolver.fulfill(Void())
            })
        }
    }

    private func refreshToken() -> HivePromise<Void> {
        return HivePromise<Void> {  resolver in
            let params: Dictionary<String, Any> = [
                "client_id" : self.authEntry.clientId,
                "scope" : self.authEntry.scope,
                "redirect_uri" : self.authEntry.redirectURL,
                "refresh_token": self.token!.refreshToken,
                "grant_type": KEYCHAIN_KEY.REFRESH_TOKEN.rawValue
            ]
            var urlRequest = URLRequest(url: URL(string: OneDriveURL.AUTH + ONEDRIVE_SUB_Url.ONEDRIVE_TOKEN.rawValue)!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = params.queryString.data(using: String.Encoding.utf8)
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            Alamofire.request(urlRequest).responseJSON(completionHandler: { dataResponse in
                guard dataResponse.response?.statusCode == 200 else{
                    let json = JSON(JSON(dataResponse.result.value as Any)["error"])
                    let error = HiveError.failue(des: json["message"].stringValue)
                    Log.e(TAG(), "RefreshToken faild: \(HiveError.des(error))")
                    resolver.reject(error)
                    return
                }
                Log.d(TAG(), "RefreshToken succeed")
                let jsonData: JSON = JSON(dataResponse.result.value as Any)
                self.token = AuthToken()
                self.token?.accessToken = jsonData[KEYCHAIN_KEY.ACCESS_TOKEN.rawValue].stringValue
                self.token?.refreshToken = jsonData[KEYCHAIN_KEY.REFRESH_TOKEN.rawValue].stringValue
                self.token?.expiredIn = jsonData[KEYCHAIN_KEY.EXPIRES_IN.rawValue].int64Value
                self.token?.expiredTime = Timestamp.getTimeAfter(time: self.token!.expiredIn)
                KeyChainStore.writeback(self.token!, self.authEntry, .oneDrive)
                resolver.fulfill(Void())
            })
        }
    }
    
    private func isExpired() -> Bool {
        return token!.isExpired()
    }

    override func checkExpired() -> HivePromise<Void> {
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
}
