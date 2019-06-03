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
        let access_token = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, .ONEDRIVEACOUNT) ?? ""
        guard access_token == "" else {
            let promise = HivePromise<Bool> { resolver in
                resolver.fulfill(true)
            }
            return promise
        }

        let promise = HivePromise<Bool> { resolver in
            self.acquireAuthCode().then({ (authCode) -> HivePromise<Bool>  in
                return self.acquireAccessToken(authCode)
            }).done({ (success) in
                handleBy.didSucceed(success)
                resolver.fulfill(success)
            }).catch({ (err) in
                let error = HiveError.failue(des: err.localizedDescription)
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
            let dataResponse = Alamofire.request(OneDriveURL.AUTH + "/logout" + "?post_logout_redirect_uri=\(self.authEntry.redirectURL)",
                method: .get,
                parameters: nil,
                encoding: JSONEncoding.default,
                headers: nil).responseJSON()
            guard dataResponse.response?.statusCode == 200 else{
                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                handleBy.runError(error)
                resolver.reject(error)
                return
            }
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
                resolver.fulfill(authCode)
            }).catch({ (error) in
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
            var urlRequest = URLRequest(url: URL(string: OneDriveURL.AUTH + OneDriveMethod.TOKEN)!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = params.queryString.data(using: String.Encoding.utf8)
            urlRequest.setValue(OneDriveHttpHeader.ContentTypeValue, forHTTPHeaderField: OneDriveHttpHeader.ContentType)
            let dataResponse = Alamofire.request(urlRequest).responseJSON()
            guard dataResponse.response?.statusCode == 200 else{
                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                resolver.reject(error)
                return
            }
            let jsonData =  JSON(dataResponse.result.value as Any)
            self.saveOnedriveAcount(jsonData)
            resolver.fulfill(true)
        }
        return promise
    }

    private func refreshAccessToken() -> HivePromise<Bool> {
        let promise = HivePromise<Bool> {  resolver in
            let refreshToken = HelperMethods.getKeychain(KEYCHAIN_REFRESH_TOKEN, .ONEDRIVEACOUNT) ?? ""
            let params: Dictionary<String, Any> = [
                "client_id" : self.authEntry.clientId,
                "scope" : self.authEntry.scope,
                "redirect_uri" : self.authEntry.redirectURL,
                "refresh_token": refreshToken,
                "grant_type": KEYCHAIN_REFRESH_TOKEN
            ]
            var urlRequest = URLRequest(url: URL(string: OneDriveURL.AUTH + OneDriveMethod.TOKEN)!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = params.queryString.data(using: String.Encoding.utf8)
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            Alamofire.request(urlRequest).responseJSON(completionHandler: { (dataResponse) in
                guard dataResponse.response?.statusCode == 200 else{
                    let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                    resolver.reject(error)
                    return
                }
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
                _ = refreshAccessToken().done{ authToken in
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
        self.token?.accessToken = jsonData[KEYCHAIN_ACCESS_TOKEN].stringValue
        self.token?.refreshToken = jsonData[KEYCHAIN_REFRESH_TOKEN].stringValue
        self.token?.expiredIn = jsonData[KEYCHAIN_EXPIRES_IN].int64
        self.token?.scopes = jsonData[KEYCHAIN_SCOPE].stringValue
        let expiredTime = HelperMethods.getExpireTime(time: self.token!.expiredIn!)
        self.token?.expiredTime = expiredTime
        let onedriveAccountJson = [KEYCHAIN_ACCESS_TOKEN: jsonData[KEYCHAIN_ACCESS_TOKEN].stringValue,
                                   KEYCHAIN_REFRESH_TOKEN: jsonData[KEYCHAIN_REFRESH_TOKEN].stringValue,
                                   KEYCHAIN_EXPIRES_IN: expiredTime,
                                   KEYCHAIN_REDIRECTURL: self.authEntry.redirectURL] as [String : Any]
        HelperMethods.saveKeychain(.ONEDRIVEACOUNT, onedriveAccountJson)
    }

    private func removeOnedriveAcount(){
        let onedriveAccountJson = [KEYCHAIN_ACCESS_TOKEN: "",
                                   KEYCHAIN_REFRESH_TOKEN: "",
                                   KEYCHAIN_EXPIRES_IN: "",
                                   KEYCHAIN_REDIRECTURL: ""]
        HelperMethods.saveKeychain(.ONEDRIVEACOUNT, onedriveAccountJson)
    }

}
