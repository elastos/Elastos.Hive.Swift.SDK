import Foundation
import Swifter
import Unirest

@inline(__always) private func TAG() -> String { return "OneDriveAuthHelper" }

@objc(OneDriveAuthHelper)
internal class OneDriveAuthHelper: AuthHelper {
    var authInfo: AuthInfo?
    private var clientId: String?
    private var scopes: String?
    private var redirectUrl: String?
    private var authCode: String?
    let server = SimpleAuthServer()
    
    init(_ clientId: String, _ scopes: Array<String>, _ redirectUrl: String) {
        self.clientId = clientId
        self.scopes = scopes.joined(separator: " ")
        self.redirectUrl = redirectUrl
    }
    
    func login(_ resultHandler: @escaping HiveResultHandler) {
        if (!hasLogin()) {
            acquireAuthorizationCode { (authCode, error) in
                guard error == nil else {
                    resultHandler(false, error)
                    return
                }
                self.authCode = authCode
                self.requestAccessToken(authCode!, { (error) in
                    guard error == nil else {
                        resultHandler(false, error)
                        return
                    }
                    resultHandler(true, nil)
                })
                self.authCode = nil
                self.server.stop()
            }
        }
    }

    func logout(_ resultHandler: @escaping HiveResultHandler) {
        UNIRest.get({ (request) in
            request?.url = ONEDRIVE_OAUTH2_BASE_REQUEST_URL + "/logout?post_logout_redirect_uri=\(self.redirectUrl!)"
        })?.asJsonAsync({ (response, error) in
            guard response?.code == 200 else {
                resultHandler(false, .jsonFailue(des: response?.body.jsonObject()))
                return
            }
            resultHandler(true, nil)
        })
    }


    private func acquireAuthorizationCode(_ authHandler: @escaping (_ authCode: String?, _ error: HiveError?) -> Void) {
        server.startRun(44316)
        server.getAuthorizationCode { (authCode, error) in
            authHandler(authCode, error)
        }
    }
    
    private func requestAccessToken(_ authorCode: String, _ hiveError: @escaping (_ error: HiveError?) -> Void) {
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
                hiveError(.systemError(error: error, jsonDes: response?.body.jsonObject()))
                return
            }
            guard response?.code == 200 else {
                hiveError(.jsonFailue(des: (response?.body.jsonObject())!))
                return
            }
            let jsonData = response?.body.jsonObject()
            guard jsonData != nil && !jsonData!.isEmpty else {
                hiveError(.failue(des: "response is nil"))
                return
            }
            self.authInfo = AuthInfo()
            self.authInfo?.accessToken = (jsonData![KEYCHAIN_ACCESS_TOKEN] as? String)
            self.authInfo?.refreshToken = (jsonData![KEYCHAIN_REFRESH_TOKEN] as? String)
            self.authInfo?.expiredIn = (jsonData![KEYCHAIN_EXPIRES_IN] as? Int64)
            self.authInfo?.scopes = (jsonData![KEYCHAIN_SCOPE] as? String)
            let expireTime = HelperMethods.getExpireTime(time: (self.authInfo?.expiredIn!)!)
            self.authInfo?.expiredTime = expireTime
            let onedriveAccountJson = [KEYCHAIN_ACCESS_TOKEN: (jsonData![KEYCHAIN_ACCESS_TOKEN] as! String) as Any,
                                       KEYCHAIN_REFRESH_TOKEN: (jsonData![KEYCHAIN_REFRESH_TOKEN] as! String),
                                       KEYCHAIN_EXPIRES_IN: expireTime] as [String : Any]
            HelperMethods.saveKeychain(KEYCHAIN_DRIVE_ACCOUNT, onedriveAccountJson)
            hiveError(nil)
        })
    }
    
    private func refreshAccessToken(_ hiveError: @escaping (_ error: HiveError?) -> Void) {
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
                hiveError(.systemError(error: error, jsonDes: response?.body.jsonObject()))
                return
            }
            guard response?.code == 200 else {
                hiveError(.jsonFailue(des: (response?.body.jsonObject())!))
                return
            }
            let jsonData = response?.body.jsonObject()
            guard jsonData != nil && !jsonData!.isEmpty else {
                hiveError(.failue(des: "response is nil"))
                return
            }
            self.authInfo = AuthInfo()
            self.authInfo?.accessToken = (jsonData![KEYCHAIN_ACCESS_TOKEN] as? String)
            self.authInfo?.refreshToken = (jsonData![KEYCHAIN_REFRESH_TOKEN] as? String)
            self.authInfo?.expiredIn = (jsonData![KEYCHAIN_EXPIRES_IN] as? Int64)
            self.authInfo?.scopes = (jsonData![KEYCHAIN_SCOPE] as? String)
            let expiredTime = HelperMethods.getExpireTime(time: self.authInfo!.expiredIn!)
            self.authInfo?.expiredTime = expiredTime

            let onedriveAccountJson = [KEYCHAIN_ACCESS_TOKEN: (jsonData![KEYCHAIN_ACCESS_TOKEN] as! String),
                                       KEYCHAIN_REFRESH_TOKEN: (jsonData![KEYCHAIN_REFRESH_TOKEN] as! String),
                                       KEYCHAIN_EXPIRES_IN: expiredTime] as [String : Any]
            HelperMethods.saveKeychain(KEYCHAIN_DRIVE_ACCOUNT, onedriveAccountJson)
            hiveError(nil)
        })
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
    
    override func checkExpired(_ errorHandler: @escaping (_ error: HiveError?) -> Void) {
        guard authInfo != nil else {
            errorHandler(.failue(des: "Have to login first"))
            return
        }

        if (isExpired()) {
            refreshAccessToken { (error) in
                errorHandler(error)
            }
        }
        else {
               errorHandler(nil)
        }
    }
}
