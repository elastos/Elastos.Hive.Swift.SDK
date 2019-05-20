import Foundation
import Swifter
import Unirest
import PromiseKit

@inline(__always) private func TAG() -> String { return "OneDriveAuthHelper" }

@objc(OneDriveAuthHelper)
internal class OneDriveAuthHelper: AuthHelper {
    var authInfo: AuthInfo?
    private var clientId: String?
    private var scopes: String?
    private var redirectUrl: String?
    private var authCode: String?
    let server = SimpleAuthServer()
    internal typealias CallbackFuture = Promise

    private let authEntry: OAuthEntry
    private var token: AuthToken?

    init(_ authEntry: OAuthEntry) {
        self.authEntry = authEntry
    }

    override func login(_ authenticator: Authenticator) -> Promise<AuthToken> {
        let promise = Promise<AuthToken> { resolver in
            acquireAuthCode().then { authCode in
                acquireAccessToken(authCode)
                authCode = nil
            }.done { authToken in
                resolver.fulfill(authToken)
                self.token = authToken
                authToken = nil
            }.catch { error in
                resolver.reject(error)
            }
        }
        return promise
    }

    override func logout() -> Promise<Bool> {
        let promise = Promise<Bool> { resolver in
            UNIRest.get { (request) in
                request?.url = OneDriveURL.AUTH + "/logout" +
                    "post_logout_redirect_uri=\(self.redirectUrl!)"
            }?.asJsonAsync{ (response, error) in
                guard response?.code == 200 else {
                    resolver.reject(HiveError.failue(des: "logout failed"))
                    return
                }
                resolver.fulfill(true)
            }
        }
        return promise
    }

    private func acquireAuthCode() -> Promise<String> {
        let promise = Promise<String> { resolver in
            server.startRun(44316)
            firstly {
                server.getCode()
            }.done { authCode in
                resolver.fulfill(authCode)
            }.catch{ error in
                resolver.reject(error)
            }
        }
        return promise
    }

    private func acquireAccessToken(_ authCode: String) -> Promise<AuthToken> {
        let promise = Promise<AuthToken> {  resolver in
            UNIRest.postEntity{ request in
                let params: Dictionary<String, Any> = [
                    "client_id" : self.authEntry.clientId,
                    "code" : authCode,
                    "grant_type" : AUTHORIZATION_TYPE_CODE,
                    "redirect_uri" : self.authEntry.redirectURL
                ]
                request?.url = OneDriveURL.AUTH + OneDriveMethod.TOKEN
                request?.headers = [OneDriveHttpHeader.ContentType: OneDriveHttpHeader.ContentTypeValue]
                request?.body = params.queryString.data(using: String.Encoding.utf8)

            }?.asJsonAsync{ (response, error) in
                guard error != nil else {
                    let _error = HiveError.failue(des: error.debugDescription)
                    resolver.reject(_error)
                    return
                }

                guard response?.code == 200 else {
                    let _error = HiveError.failue(des: response?.description)
                    resolver.reject(_error)
                    return
                }

                let jsonObject = response?.body.jsonObject() as? [String: String]
                guard jsonObject != nil &&  !jsonObject!.isEmpty else {
                    resolver.reject(HiveError.failue(des: "Empty response body"))
                    return
                }

                let token = AuthToken(jsonObject!["scope"]!,
                                      jsonObject!["access_token"]!,
                                      jsonObject!["refresh_token"]!,
                                      jsonObject!["expires_in"]!)
                resolver.fulfill(token)
            }
        }

        return promise
    }

    private func refreshAccessToken() -> Promise<AuthToken> {
        let promise = Promise<AuthToken> {  resolver in
            UNIRest.postEntity{ request in
                let params: Dictionary<String, Any> = [
                    "client_id" : self.authEntry.clientId,
                    "scope" : self.authEntry.scope,
                    "redirect_uri" : self.authEntry.redirectURL,
                    "refresh_token": self.token!.refreshToken,
                    "grant_type": KEYCHAIN_REFRESH_TOKEN
                ]
                request?.url = OneDriveURL.AUTH + OneDriveMethod.TOKEN
                request?.headers = [OneDriveHttpHeader.ContentType: OneDriveHttpHeader.ContentTypeValue]
                request?.body = params.queryString.data(using: String.Encoding.utf8)

            }?.asJsonAsync{ (response, error) in
                guard error != nil else {
                    let _error = HiveError.failue(des: error.debugDescription)
                    resolver.reject(_error)
                    return
                }

                guard response?.code == 200 else {
                    let _error = HiveError.failue(des: response?.description)
                    resolver.reject(_error)
                    return
                }

                let jsonObject = response?.body.jsonObject() as? [String: String]
                guard jsonObject != nil &&  !jsonObject!.isEmpty else {
                    resolver.reject(HiveError.failue(des: "Empty response body"))
                    return
                }

                let token = AuthToken(jsonObject!["scope"]!,
                                      jsonObject!["access_token"]!,
                                      jsonObject!["refresh_token"]!,
                                      jsonObject!["expires_in"]!)
                resolver.fulfill(token)
            }
        }

        return promise
    }
    
    private func isExpired() -> Bool {
        return token == nil || token!.isExpired()
    }

    override func checkExpired() -> Promise<Bool> {
        let promise = Promise<Bool> { resolver in
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

    /*
    private func saveOnedriveAcount(_ jsonData: Dictionary<String, Any>){
        self.authInfo = AuthInfo()
        self.authInfo?.accessToken = (jsonData[KEYCHAIN_ACCESS_TOKEN] as? String)
        self.authInfo?.refreshToken = (jsonData[KEYCHAIN_REFRESH_TOKEN] as? String)
        self.authInfo?.expiredIn = (jsonData[KEYCHAIN_EXPIRES_IN] as? Int64)
        self.authInfo?.scopes = (jsonData[KEYCHAIN_SCOPE] as? String)
        let expiredTime = HelperMethods.getExpireTime(time: self.authInfo!.expiredIn!)
        self.authInfo?.expiredTime = expiredTime
        let onedriveAccountJson = [KEYCHAIN_ACCESS_TOKEN: (jsonData[KEYCHAIN_ACCESS_TOKEN] as! String),
                                   KEYCHAIN_REFRESH_TOKEN: (jsonData[KEYCHAIN_REFRESH_TOKEN] as! String),
                                   KEYCHAIN_EXPIRES_IN: expiredTime] as [String : Any]
        HelperMethods.saveKeychain(KEYCHAIN_DRIVE_ACCOUNT, onedriveAccountJson)
    }
    */
}
