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

    
    init(_ clientId: String, _ scopes: Array<String>, _ redirectUrl: String) {
        self.clientId = clientId
        self.scopes = scopes.joined(separator: " ")
        self.redirectUrl = redirectUrl
    }

    func login() -> CallbackFuture<Bool> {

        let future = CallbackFuture<Bool> { resolver in
            if (!hasLogin()) {
                _ = acquireAuthorizationCode().done({ (authCode) in
                    self.authCode = authCode
                    _ = self.requestAccessToken(authCode).done({ (result) in
                        self.authCode = nil
                        self.server.stop()
                        resolver.fulfill(result)
                    })
                })
            }
            else{
                resolver.fulfill(true)
            }
        }
        return future
    }

    func logout() -> CallbackFuture<Bool> {
        let future = CallbackFuture<Bool>{ resolver in
            UNIRest.get({ (request) in
                request?.url = "\(ONEDRIVE_OAUTH2_BASE_REQUEST_URL)/logout?post_logout_redirect_uri=\(self.redirectUrl!)"
            })?.asJsonAsync({ (response, error) in
                guard response?.code == 200 else {
                    resolver.reject(HiveError.failue(des: "logout failed"))
                    return
                }
                resolver.fulfill(true)
            })
        }
        return  future
    }

    private func acquireAuthorizationCode() -> CallbackFuture<String> {

        let future = CallbackFuture<String> { resolver in
            server.startRun(44316)
            _ = server.getAuthorizationCode().done({ (authCode) in
                resolver.fulfill(authCode)
            }).catch({ (error) in
                resolver.reject(error)
            })
        }
        return future
    }
    
    private func requestAccessToken(_ authorCode: String) -> CallbackFuture<Bool> {
        let future = CallbackFuture<Bool> { resolver in

            let params: Dictionary<String, Any> = ["client_id" : clientId ?? "",
                                                   "code" : authorCode,
                                                   "grant_type" : AUTHORIZATION_TYPE_CODE,
                                                   "redirect_uri" : redirectUrl ?? ""]
            UNIRest.postEntity { (request) in
                request?.url = String(format: ONEDRIVE_OAUTH2_BASE_REQUEST_URL + "/token")
                request?.headers = ["Content-Type": "application/x-www-form-urlencoded"]
                request?.body = params.queryString.data(using: String.Encoding.utf8)
                }?.asJsonAsync({ (response, error) in
                    guard error == nil else {
                        resolver.reject(HiveError.systemError(error: error, jsonDes: response?.body.jsonObject()))
                        return
                    }
                    guard response?.code == 200 else {
                        resolver.reject(HiveError.jsonFailue(des: response?.body.jsonObject()))
                        return
                    }
                    let jsonData = response?.body.jsonObject()
                    guard jsonData != nil && !jsonData!.isEmpty else {
                        resolver.reject(HiveError.failue(des: "response is nil"))
                        return
                    }
                    self.saveOnedriveAcount(jsonData as! Dictionary<String, Any>)
                    resolver.fulfill(true)
                })
        }
        return future
    }
    
    private func refreshAccessToken() -> CallbackFuture<Bool> {
        let future = CallbackFuture<Bool>{ resolver in
            let scope = ["Files.ReadWrite","offline_access"].joined(separator: " ")
            let refreshToken = HelperMethods.getKeychain(KEYCHAIN_REFRESH_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
            let params: Dictionary<String, Any> = ["client_id": clientId ?? "",
                                                   "refresh_token": refreshToken,
                                                   "grant_type": KEYCHAIN_REFRESH_TOKEN,
                                                   "redirect_uri": redirectUrl ?? "",
                                                   "scope": scope]
            UNIRest.postEntity { (request) in
                request?.url = String(format: ONEDRIVE_OAUTH2_BASE_REQUEST_URL + "/token")
                request?.headers = ["Content-Type": "application/x-www-form-urlencoded"]
                request?.body = params.queryString.data(using: String.Encoding.utf8)
                }?.asJsonAsync({ (response, error) in
                    guard error == nil else {
                        resolver.reject(HiveError.systemError(error: error, jsonDes: response?.body.jsonObject()))
                        return
                    }
                    guard response?.code == 200 else {
                        resolver.reject(HiveError.jsonFailue(des: response?.body.jsonObject()))
                        return
                    }
                    let jsonData = response?.body.jsonObject()
                    guard jsonData != nil && !jsonData!.isEmpty else {
                        resolver.reject(HiveError.failue(des: "response is nil"))
                        return
                    }
                    self.saveOnedriveAcount(jsonData as! Dictionary<String, Any>)
                    resolver.fulfill(true)
                })
        }
        return future
    }
    
    private func hasLogin() -> Bool {
        return authInfo != nil;
    }
    
    private func isExpired() -> Bool {
        guard authInfo != nil else {
            return true;
        }
        return (authInfo?.isExpired())!
    }
    
    override func checkExpired() -> CallbackFuture<Bool>? {
        let future = CallbackFuture<Bool>{ resolver in

            guard authInfo != nil else {
                resolver.reject(HiveError.failue(des: "Have to login first"))
                return
            }
            if isExpired() {
                _ = self.refreshAccessToken().done({ (result) in
                    resolver.fulfill(result)
                }).catch({ (error) in
                    resolver.reject(error)
                })
            }
            else {
                resolver.fulfill(true)
            }
        }
        return future
    }

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
}
