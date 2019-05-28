import Foundation
import Swifter
import Unirest
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

    override func login(_ authenticator: Authenticator) -> Bool {
        let authCode = acquireAuthCode()
        let result = self.acquireAccessToken(authCode)
        return result
    }

    override func logout() -> Bool {
        var result = false
        let dataResponse = Alamofire.request(OneDriveURL.AUTH + "/logout" + "?post_logout_redirect_uri=\(self.authEntry.redirectURL)",
                                            method: .get,
                                            parameters: nil,
                                            encoding: JSONEncoding.default,
                                            headers: nil).responseJSON()
        dataResponse.result.ifSuccess {
            guard dataResponse.response?.statusCode == 200 else{
                result = false
                return
            }
            result = true
        }
        dataResponse.result.ifFailure {
            result = false
            return
        }
        return result
    }

    private func acquireAuthCode() -> String {
        server.startRun(44316)
        return server.getCode()
    }

    private func acquireAccessToken(_ authCode: String) -> Bool {
        var result = false
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
        dataResponse.result.ifSuccess {
            guard dataResponse.response?.statusCode == 200 else{
                result = false
                return
            }
            let jsonData = dataResponse.result.value as? [String: Any]
            guard jsonData != nil else {
                result = false
                return
            }
            self.saveOnedriveAcount(jsonData!)
            result = true
        }
        dataResponse.result.ifFailure {
            result = false
            return
        }
        return result
    }

    private func refreshAccessToken() -> HivePromise<Bool> {
        let promise = HivePromise<Bool> {  resolver in
            let refreshToken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
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
                dataResponse.result.ifSuccess {
                    guard dataResponse.response?.statusCode == 200 else{
                        let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                        resolver.reject(error)
                        return
                    }
                    let jsonData = dataResponse.result.value as? [String: Any]
                    guard jsonData != nil else {
                        resolver.reject(HiveError.failue(des: "Empty response body"))
                        return
                    }
                    self.saveOnedriveAcount(jsonData!)
                    resolver.fulfill(true)
                }
                dataResponse.result.ifFailure {
                    let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                    resolver.reject(error)
                    return
                }
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

    private func saveOnedriveAcount(_ jsonData: Dictionary<String, Any>){
        self.token = AuthToken()
        self.token?.accessToken = (jsonData[KEYCHAIN_ACCESS_TOKEN] as? String)
        self.token?.refreshToken = (jsonData[KEYCHAIN_REFRESH_TOKEN] as? String)
        self.token?.expiredIn = (jsonData[KEYCHAIN_EXPIRES_IN] as? Int64)
        self.token?.scopes = (jsonData[KEYCHAIN_SCOPE] as? String)
        let expiredTime = HelperMethods.getExpireTime(time: self.token!.expiredIn!)
        self.token?.expiredTime = expiredTime
        let onedriveAccountJson = [KEYCHAIN_ACCESS_TOKEN: (jsonData[KEYCHAIN_ACCESS_TOKEN] as! String),
                                   KEYCHAIN_REFRESH_TOKEN: (jsonData[KEYCHAIN_REFRESH_TOKEN] as! String),
                                   KEYCHAIN_EXPIRES_IN: expiredTime] as [String : Any]
        HelperMethods.saveKeychain(KEYCHAIN_DRIVE_ACCOUNT, onedriveAccountJson)
    }

}
