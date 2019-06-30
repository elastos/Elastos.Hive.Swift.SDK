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

    override func loginAsync(_ authenticator: Authenticator) -> HivePromise<HiveVoid> {
        return loginAsync(authenticator, handleBy: HiveCallback<HiveVoid>())
    }

    override func loginAsync(_ authenticator: Authenticator, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        guard token == nil else {
            let promise = HivePromise<HiveVoid> { resolver in
                Log.d(TAG(), "OneDrive already logined")
                token = KeyChainStore.restoreToken(.oneDrive)
                authEntry = KeyChainStore.restoreAuthEntry(.oneDrive)!
                let padding = HiveVoid()
                handleBy.didSucceed(padding)
                resolver.fulfill(padding)
            }
            return promise
        }

        let promise = HivePromise<HiveVoid> { resolver in
            self.acquireAuthCode(authenticator)
            .then { authCode -> HivePromise<HiveVoid>  in
                return self.acquireAccessToken(authCode)
            }.done { padding in
                Log.d(TAG(), "Login succeed")
                handleBy.didSucceed(padding)
                resolver.fulfill(padding)
            }.catch { err in
                let error = HiveError.failue(des: err.localizedDescription)
                Log.e(TAG(), "Login faild: %s",error.localizedDescription)
                handleBy.runError(error)
                resolver.reject(error)
            }
        }
        return promise
    }

    override func logoutAsync() -> HivePromise<HiveVoid> {
        return logoutAsync(handleBy: HiveCallback<HiveVoid>())
    }

    override func logoutAsync(handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            Alamofire.request(OneDriveURL.AUTH + ONEDRIVE_SUB_Url.ONEDRIVE_LOGOUT.rawValue + "?post_logout_redirect_uri=\(authEntry.redirectURL)",
                method: .get,
                parameters: nil,
                encoding: JSONEncoding.default,
                headers: nil).responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.response?.statusCode == 200 else{
                        let error = HiveError.failue(des: dataResponse.toString())
                        Log.e(TAG(), "Logout faild: %s",error.localizedDescription)
                        handleBy.runError(error)
                        resolver.reject(error)
                        return
                    }
                    Log.d(TAG(), "Logout succeed")
                    self.token = nil
                    KeyChainStore.removeback(authEntry: self.authEntry, forDrive: .oneDrive)
                    let padding = HiveVoid()
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
            server.getCode().done({ (authCode) in
                Log.d(TAG(), "AuthCode succeed")
                resolver.fulfill(authCode)
            }).catch({ (error) in
                Log.e(TAG(), "AuthCode faild: %s",error.localizedDescription)
                resolver.reject(error)
            })
        }
        return promise
    }

    private func acquireAccessToken(_ authCode: String) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
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
            Alamofire.request(urlRequest).responseJSON(completionHandler: { (dataResponse) in
                guard dataResponse.response?.statusCode == 200 else{
                    let error = HiveError.failue(des: dataResponse.toString())
                    Log.e(TAG(), "AccessToken faild: %s",error.localizedDescription)
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
                resolver.fulfill(HiveVoid())
            })
        }
        return promise
    }

    private func refreshToken() -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> {  resolver in
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
            Alamofire.request(urlRequest).responseJSON(completionHandler: { (dataResponse) in
                guard dataResponse.response?.statusCode == 200 else{
                    let error = HiveError.failue(des: dataResponse.toString())
                    Log.e(TAG(), "RefreshToken faild: %s",error.localizedDescription)
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
                resolver.fulfill(HiveVoid())
            })
        }
        return promise
    }
    
    private func isExpired() -> Bool {
        return token == nil || token!.isExpired()
    }

    override func checkExpired() -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            guard !isExpired() else {
                _ = refreshToken().done{ authToken in
                    resolver.fulfill(HiveVoid())
                }.catch{ error in
                    resolver.reject(error)
                }
                return
            }
            resolver.fulfill(HiveVoid())
        }
        return promise
    }
}
