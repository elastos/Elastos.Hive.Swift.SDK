import Foundation
import Swifter
import PromiseKit
import Alamofire

@inline(__always) private func TAG() -> String { return "OneDriveAuthHelper" }

@objc(OneDriveAuthHelper)
internal class OneDriveAuthHelper: AuthHelper {
    var token: AuthToken?
    let server = SimpleAuthServer()
    private let authEntry: OAuthEntry

    init(_ authEntry: OAuthEntry) {
        self.authEntry = authEntry
    }

    override func loginAsync(_ authenticator: Authenticator) -> HivePromise<Bool> {
        return loginAsync(authenticator, handleBy: HiveCallback<Bool>())
    }

    override func loginAsync(_ authenticator: Authenticator, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let access_token = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
        guard access_token == "" else {
            let promise = HivePromise<Bool> { resolver in
                self.token = AuthToken()
                self.token?.accessToken = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
                self.token?.refreshToken = HelperMethods.getKeychain(KEYCHAIN_KEY.REFRESH_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
                Log.d(TAG(), "Already logged")
                resolver.fulfill(true)
            }
            return promise
        }

        let promise = HivePromise<Bool> { resolver in
            self.acquireAuthCode().then({ (authCode) -> HivePromise<Bool>  in
                return self.acquireAccessToken(authCode)
            }).done({ (success) in
                Log.d(TAG(), "Login succeed")
                handleBy.didSucceed(success)
                resolver.fulfill(success)
            }).catch({ (err) in
                let error = HiveError.failue(des: err.localizedDescription)
                Log.e(TAG(), "Login faild: %s",error.localizedDescription)
                handleBy.runError(error)
                resolver.reject(error)
            })
        }
        return promise
    }

    override func logoutAsync() -> HivePromise<Bool> {
        return logoutAsync(handleBy: HiveCallback<Bool>())
    }

    override func logoutAsync(handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            let dataResponse = Alamofire.request(OneDriveURL.AUTH + ONEDRIVE_SUB_Url.ONEDRIVE_LOGOUT.rawValue + "?post_logout_redirect_uri=\(self.authEntry.redirectURL)",
                method: .get,
                parameters: nil,
                encoding: JSONEncoding.default,
                headers: nil).responseJSON()
            guard dataResponse.response?.statusCode == 200 else{
                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                Log.e(TAG(), "Logout faild: %s",error.localizedDescription)
                handleBy.runError(error)
                resolver.reject(error)
                return
            }
            Log.d(TAG(), "Logout succeed")
            self.token = nil
            self.removeOnedriveAcount()
            handleBy.didSucceed(true)
            resolver.fulfill(true)
        }
        return promise
    }

    private func acquireAuthCode() -> HivePromise<String> {
        let promise = HivePromise<String> { resolver in
            let redirecturl = self.authEntry.redirectURL
            let startIndex = redirecturl.index(redirecturl.startIndex, offsetBy: 17)
            let endIndex =  redirecturl.index(redirecturl.startIndex, offsetBy: redirecturl.count)
            let port = UInt16(redirecturl[startIndex..<endIndex])
            server.startRun(port!)
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

    private func acquireAccessToken(_ authCode: String) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
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
            let dataResponse = Alamofire.request(urlRequest).responseJSON()
            guard dataResponse.response?.statusCode == 200 else{
                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                Log.e(TAG(), "AccessToken faild: %s",error.localizedDescription)
                resolver.reject(error)
                return
            }
            Log.d(TAG(), "AccessToken succeed")
            let jsonData =  JSON(dataResponse.result.value as Any)
            self.saveOnedriveAcount(jsonData)
            resolver.fulfill(true)
        }
        return promise
    }

    private func refreshToken() -> HivePromise<Bool> {
        let promise = HivePromise<Bool> {  resolver in
            let refreshToken = HelperMethods.getKeychain(KEYCHAIN_KEY.REFRESH_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
            let params: Dictionary<String, Any> = [
                "client_id" : self.authEntry.clientId,
                "scope" : self.authEntry.scope,
                "redirect_uri" : self.authEntry.redirectURL,
                "refresh_token": refreshToken,
                "grant_type": KEYCHAIN_KEY.REFRESH_TOKEN.rawValue
            ]
            var urlRequest = URLRequest(url: URL(string: OneDriveURL.AUTH + ONEDRIVE_SUB_Url.ONEDRIVE_TOKEN.rawValue)!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = params.queryString.data(using: String.Encoding.utf8)
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            Alamofire.request(urlRequest).responseJSON(completionHandler: { (dataResponse) in
                guard dataResponse.response?.statusCode == 200 else{
                    let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                    Log.e(TAG(), "RefreshToken faild: %s",error.localizedDescription)
                    resolver.reject(error)
                    return
                }
                Log.d(TAG(), "RefreshToken succeed")
                let jsonData = JSON(dataResponse.result.value as Any)
                self.saveOnedriveAcount(jsonData)
                resolver.fulfill(true)
            })
        }
        return promise
    }
    
    private func isExpired() -> Bool {
        return token == nil || token!.isExpired()
    }

    override func checkExpired() -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            guard !isExpired() else {
                _ = refreshToken().done{ authToken in
                    resolver.fulfill(true)
                }.catch{ error in
                    resolver.reject(error)
                }
                return
            }
            resolver.fulfill(true)
        }
        return promise
    }

    private func saveOnedriveAcount(_ jsonData: JSON){
        self.token = AuthToken()
        self.token?.accessToken = jsonData[KEYCHAIN_KEY.ACCESS_TOKEN.rawValue].stringValue
        self.token?.refreshToken = jsonData[KEYCHAIN_KEY.REFRESH_TOKEN.rawValue].stringValue
        self.token?.expiredIn = jsonData[KEYCHAIN_KEY.EXPIRES_IN.rawValue].int64
        let expiredTime = HelperMethods.getExpireTime(time: self.token!.expiredIn!)
        self.token?.expiredTime = expiredTime
        let onedriveAccountJson = [KEYCHAIN_KEY.ACCESS_TOKEN.rawValue: jsonData[KEYCHAIN_KEY.ACCESS_TOKEN.rawValue].stringValue,
                                   KEYCHAIN_KEY.REFRESH_TOKEN.rawValue: jsonData[KEYCHAIN_KEY.REFRESH_TOKEN.rawValue].stringValue,
                                   KEYCHAIN_KEY.EXPIRES_IN.rawValue: expiredTime,
                                   KEYCHAIN_KEY.REDIRECTURL.rawValue: self.authEntry.redirectURL,
                                   KEYCHAIN_KEY.CLIENT_ID.rawValue: self.authEntry.clientId,
                                   KEYCHAIN_KEY.SCOPE.rawValue: self.authEntry.scope
                                   ] as [String : Any]
        HelperMethods.saveKeychain(.ONEDRIVEACOUNT, onedriveAccountJson)
    }

    private func removeOnedriveAcount(){
        let onedriveAccountJson = [KEYCHAIN_KEY.ACCESS_TOKEN.rawValue: "",
                                   KEYCHAIN_KEY.REFRESH_TOKEN.rawValue: "",
                                   KEYCHAIN_KEY.EXPIRES_IN.rawValue: "",
                                   KEYCHAIN_KEY.REDIRECTURL.rawValue: "",
                                   KEYCHAIN_KEY.REDIRECTURL.rawValue: self.authEntry.redirectURL,
                                   KEYCHAIN_KEY.CLIENT_ID.rawValue: self.authEntry.clientId,
                                   KEYCHAIN_KEY.SCOPE.rawValue: self.authEntry.scope]
        HelperMethods.saveKeychain(.ONEDRIVEACOUNT, onedriveAccountJson)
    }

}
