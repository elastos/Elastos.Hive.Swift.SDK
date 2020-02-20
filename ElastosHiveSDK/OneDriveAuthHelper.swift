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
    let expireAtKey: String = "expires_at"
    
    var clientId: String
    var scope: String
    var redirectUrl: String
    var persistentStorePath: String
    var token: AuthToken?
    let server = SimpleAuthServer.sharedInstance
    var connectState: Bool = false
    
    init(_ clientId: String, _ scope: String, _ redirectUrl: String, _ persistentStorePath: String) {
        self.clientId = clientId
        self.scope = scope
        self.redirectUrl = redirectUrl
        self.persistentStorePath = persistentStorePath
    }

    override func connectAsync(authenticator: Authenticator? = nil) -> HivePromise<Void> {
        return connectAsync(authenticator: authenticator, handleBy: HiveCallback<Void>())
    }

    override func connectAsync(authenticator: Authenticator? = nil, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        // todo: store
        return HivePromise<Void> { resolver in
            self.acquireAuthCode(authenticator!)
                .then { authCode -> HivePromise<Void>  in
                    return self.acquireAccessToken(authCode)
                }.done { padding in
                    Log.d(TAG(), "Login succeed")
                    handleBy.didSucceed(padding)
                    resolver.fulfill(padding)
                }.catch { error in
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
            return _ = self.logoutAsync_().done { _ in
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
    
    private func login(_ authenticator: Authenticator) throws -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
    }
    
    private func tryRestoreToken() {
        //TODO:
    }
    
    private func acquireAuthCode(_ authenticator: Authenticator) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            let startIndex: String.Index = redirectUrl.index(redirectUrl.startIndex, offsetBy: 17)
            let endIndex: String.Index =  redirectUrl.index(redirectUrl.startIndex, offsetBy: redirectUrl.count)
            let port = UInt16(redirectUrl[startIndex..<endIndex])
            let param = "client_id=\(clientId)&scope=\(scope)&response_type=code&redirect_uri=\(redirectUrl)"

            let url = OneDriveURL(param).acquireAuthCode()
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
            let url = OneDriveURL("").token()
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
//                let jsonData: JSON =  JSON(dataResponse.result.value as Any)
//              TODO: save info
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
            let url = OneDriveURL("").token()
            var urlRequest = URLRequest(url: URL(string: url)!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = params.queryString.data(using: String.Encoding.utf8)
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            Alamofire.request(urlRequest).responseJSON(completionHandler: { dataResponse in
                guard dataResponse.response?.statusCode == 200 else{
                    let json = JSON(JSON(dataResponse.result.value as Any)["error"])
                    let error = HiveError.failue(des: json["message"].stringValue)
                    resolver.reject(error)
                    return
                }
                Log.d(TAG(), "RefreshToken succeed")
//                let jsonData: JSON = JSON(dataResponse.result.value as Any)
//              TODO: save info
                resolver.fulfill(Void())
            })
        }
    }
    
    private func isExpired() -> Bool {
        return token!.isExpired()
    }

    private func logoutAsync_() -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            let url: String = OneDriveURL(redirectUrl).logout()
            OneDriveAPIs.request(url: url,
                                 method: .get,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: nil,
                                 self).done { jsonData in
                    Log.d(TAG(), "Logout succeed")
                    //   TODO: remove local info
                    resolver.fulfill(Void())
            }
            .catch { error in
                resolver.reject(error)
            }
        }
    }
}
