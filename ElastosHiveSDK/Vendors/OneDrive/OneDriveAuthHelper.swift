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
import Swifter
import PromiseKit
import Alamofire

@inline(__always) private func TAG() -> String { return "OneDriveAuthHelper" }

@objc(OneDriveAuthHelper)
internal class OneDriveAuthHelper: AuthHelper {
    var token: AuthToken?
    let server = SimpleAuthServer()
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
            let promise = HivePromise<Void> { resolver in
                Log.d(TAG(), "OneDrive already logined")
                authEntry = KeyChainStore.restoreAuthEntry(.oneDrive)!
                let padding = Void()
                handleBy.didSucceed(padding)
                resolver.fulfill(padding)
            }
            return promise
        }

        let promise = HivePromise<Void> { resolver in
            self.acquireAuthCode(authenticator)
                .then { authCode -> HivePromise<Void>  in
                    return self.acquireAccessToken(authCode)
                }.done { padding in
                    Log.d(TAG(), "Login succeed")
                    handleBy.didSucceed(padding)
                    resolver.fulfill(padding)
                }.catch { error in
                    Log.e(TAG(), "Login faild: " + HiveError.des(error as! HiveError))
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func logoutAsync() -> HivePromise<Void> {
        return logoutAsync(handleBy: HiveCallback<Void>())
    }

    override func logoutAsync(handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let promise = HivePromise<Void> { resolver in
            Alamofire.request(OneDriveURL.AUTH + ONEDRIVE_SUB_Url.ONEDRIVE_LOGOUT.rawValue + "?post_logout_redirect_uri=\(authEntry.redirectURL)",
                method: .get,
                parameters: nil,
                encoding: JSONEncoding.default,
                headers: nil).responseJSON(completionHandler: { dataResponse in
                    guard dataResponse.response?.statusCode == 200 else{
                        let json = JSON(JSON(dataResponse.result.value as Any)["error"])
                        let error = HiveError.failue(des: json["message"].stringValue)
                        Log.e(TAG(), "Logout faild: " + HiveError.des(error))
                        handleBy.runError(error)
                        resolver.reject(error)
                        return
                    }
                    Log.d(TAG(), "Logout succeed")
                    self.token = nil
                    KeyChainStore.removeback(authEntry: self.authEntry, forDrive: .oneDrive)
                    let padding = Void()
                    handleBy.didSucceed(padding)
                    resolver.fulfill(padding)
                })
        }
        return promise
    }

    private func acquireAuthCode(_ authenticator: Authenticator) -> HivePromise<String> {
        let promise = HivePromise<String> { resolver in
            let redirecturl = authEntry.redirectURL
            let startIndex = redirecturl.index(redirecturl.startIndex, offsetBy: 17)
            let endIndex =  redirecturl.index(redirecturl.startIndex, offsetBy: redirecturl.count)
            let port = UInt16(redirecturl[startIndex..<endIndex])
            server.startRun(port!)
            _ = authenticator.requestAuthentication(redirecturl)
            server.getCode().done{ authCode in
                Log.d(TAG(), "AuthCode succeed")
                resolver.fulfill(authCode)
                }.catch{ error in
                    Log.e(TAG(), "AuthCode faild: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
            }
        }
        return promise
    }

    private func acquireAccessToken(_ authCode: String) -> HivePromise<Void> {
        let promise = HivePromise<Void> { resolver in
            let params: Dictionary<String, Any> = [
                "client_id" : self.authEntry.clientId,
                "code" : authCode,
                "grant_type" : AUTHORIZATION_TYPE_CODE,
                "redirect_uri" : self.authEntry.redirectURL
            ]
            var urlRequest = URLRequest(url: URL(string: OneDriveURL.AUTH + ONEDRIVE_SUB_Url.ONEDRIVE_TOKEN.rawValue)!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = params.queryString.data(using: String.Encoding.utf8)
            urlRequest.setValue(OneDriveHttpHeader.ContentTypeValue, forHTTPHeaderField: OneDriveHttpHeader.ContentType)
            Alamofire.request(urlRequest).responseJSON(completionHandler: { dataResponse in
                guard dataResponse.response?.statusCode == 200 else{
                    let error = HiveError.failue(des: dataResponse.toString())
                    Log.e(TAG(), "AccessToken faild: " + HiveError.des(error))
                    resolver.reject(error)
                    return
                }
                Log.d(TAG(), "AccessToken succeed")
                let jsonData =  JSON(dataResponse.result.value as Any)
                self.token = AuthToken()
                self.token?.accessToken = jsonData[KEYCHAIN_KEY.ACCESS_TOKEN.rawValue].stringValue
                self.token?.refreshToken = jsonData[KEYCHAIN_KEY.REDIRECTURL.rawValue].stringValue
                self.token?.expiredIn = jsonData[KEYCHAIN_KEY.EXPIRES_IN.rawValue].int64Value
                self.token?.expiredTime = Timestamp.getTimeAfter(time: self.token!.expiredIn)
                KeyChainStore.writeback(self.token!, self.authEntry, .oneDrive)
                resolver.fulfill(Void())
            })
        }
        return promise
    }

    private func refreshToken() -> HivePromise<Void> {
        let promise = HivePromise<Void> {  resolver in
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
                    Log.e(TAG(), "RefreshToken faild: " + HiveError.des(error))
                    resolver.reject(error)
                    return
                }
                Log.d(TAG(), "RefreshToken succeed")
                let jsonData = JSON(dataResponse.result.value as Any)
                self.token = AuthToken()
                self.token?.accessToken = jsonData[KEYCHAIN_KEY.ACCESS_TOKEN.rawValue].stringValue
                self.token?.refreshToken = jsonData[KEYCHAIN_KEY.REDIRECTURL.rawValue].stringValue
                self.token?.expiredIn = jsonData[KEYCHAIN_KEY.EXPIRES_IN.rawValue].int64Value
                self.token?.expiredTime = Timestamp.getTimeAfter(time: self.token!.expiredIn)
                KeyChainStore.writeback(self.token!, self.authEntry, .oneDrive)
                resolver.fulfill(Void())
            })
        }
        return promise
    }
    
    private func isExpired() -> Bool {
        return token!.isExpired()
    }

    override func checkExpired() -> HivePromise<Void> {
        let promise = HivePromise<Void> { resolver in
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
        return promise
    }
}
