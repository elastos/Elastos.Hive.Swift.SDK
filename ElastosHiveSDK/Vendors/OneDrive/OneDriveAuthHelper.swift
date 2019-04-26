import Foundation
import Swifter
import Unirest

@inline(__always) private func TAG() -> String { return "OneDriveAuthHelper" }

@objc(OneDriveAuthHelper)
internal class OneDriveAuthHelper: AuthHelper {
    typealias ResponseHandle = (_ respondeJson: Dictionary<String, Any>?, _ error: HiveError?) -> Void
    typealias HandleResulr = (_ result: Bool?, _ error: HiveError?) -> Void
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
    
    func login(_ result: @escaping HandleResulr) {
        if (!hasLogin()) {
            acquireAuthorizationCode { (authCode, error) in
                guard error == nil else {
                    result(false, error)
                    return
                }
                self.authCode = authCode
                self.requestAccessToken(authCode!, { (error) in
                    if error != nil {
                        result(false, error)
                    }
                    result(true, nil)
                })
                self.authCode = nil
                self.server.stop()
            }
        }
    }

    func logout(_ result: @escaping HandleResulr) {
        UNIRest.get({ (request) in
            request?.url = BASE_REQURL + "/logout?post_logout_redirect_uri=\(self.redirectUrl!)"
        })?.asJsonAsync({ (response, error) in
            if response?.code != 200 {
                result(false, .jsonFailue(des: response?.body.jsonObject()))
            }
            result(true, nil)
        })
    }


    private func acquireAuthorizationCode(_ authHandle: @escaping (_ authCode: String?, _ error: HiveError?) -> Void) {
        server.startRun(44316)
        server.getAuthorizationCode { (authCode, error) in
            authHandle(authCode, error)
        }
    }
    
    private func requestAccessToken(_ authorCode: String, _ hiveError: @escaping (_ error: HiveError?) -> Void) {

        let params: Dictionary<String, Any> = ["client_id" : clientId ?? "",
                                               "code" : authorCode,
                                               "grant_type" : AUTHORIZATION_CODE,
                                               "redirect_uri" : redirectUrl ?? ""]
        UNIRest.postEntity { (request) in
            request?.url = String(format: BASE_REQURL + "/token")
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
                if jsonData == nil || jsonData!.isEmpty {
                    hiveError(.failue(des: "response is nil"))
                    return
                }
                self.authInfo = AuthInfo()
                self.authInfo?.accessToken = (jsonData![ACCESS_TOKEN] as? String)
                self.authInfo?.refreshToken = (jsonData![REFRESH_TOKEN] as? String)
                self.authInfo?.expiredIn = (jsonData![EXPIRES_IN] as? Int64)
                self.authInfo?.scopes = (jsonData![SCOPE] as? String)
                let expireTime = HelperMethods.getExpireTime(time: (self.authInfo?.expiredIn!)!)
                self.authInfo?.expiredTime = expireTime
                let onedriveAccountJson = [ACCESS_TOKEN: (jsonData![ACCESS_TOKEN] as! String) as Any, REFRESH_TOKEN: (jsonData![REFRESH_TOKEN] as! String), EXPIRES_IN: expireTime] as [String : Any]
                HelperMethods.savekeychain(ONEDRIVE_ACCOUNT, onedriveAccountJson)
                hiveError(nil)
            })
    }
    
    private func refreshAccessToken(_ hiveError: @escaping (_ error: HiveError?) -> Void) {

        let scops = ["Files.ReadWrite","offline_access"]
        let scopStr = scops.joined(separator: " ")
        let refreshToken = HelperMethods.getkeychain(REFRESH_TOKEN, ONEDRIVE_ACCOUNT) ?? ""
        let params: Dictionary<String, Any> = ["client_id": clientId ?? "",
                                               "refresh_token": refreshToken,
                                               "grant_type": REFRESH_TOKEN,
                                               "redirect_uri": redirectUrl ?? "",
                                               "scope": scopStr
        ]
        UNIRest.postEntity { (request) in
            request?.url = String(format: BASE_REQURL + "/token")
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
                if jsonData == nil || jsonData!.isEmpty {
                    hiveError(.failue(des: "response is nil"))
                    return
                }
                self.authInfo = AuthInfo()
                self.authInfo?.accessToken = (jsonData![ACCESS_TOKEN] as? String)
                self.authInfo?.refreshToken = (jsonData![REFRESH_TOKEN] as? String)
                self.authInfo?.expiredIn = (jsonData![EXPIRES_IN] as? Int64)
                self.authInfo?.scopes = (jsonData![SCOPE] as? String)
                let expireTime = HelperMethods.getExpireTime(time: self.authInfo!.expiredIn!)
                self.authInfo?.expiredTime = expireTime
                let onedriveAccountJson = [ACCESS_TOKEN: (jsonData![ACCESS_TOKEN] as! String), REFRESH_TOKEN: (jsonData![REFRESH_TOKEN] as! String), EXPIRES_IN: expireTime] as [String : Any]
                //save to keychain: access_token & refresh_token & expire_time
                HelperMethods.savekeychain(ONEDRIVE_ACCOUNT, onedriveAccountJson)
                hiveError(nil)
            })
    }
    
    private func hasLogin() -> Bool {
        return authInfo != nil;
    }
    
    private func isExpired() -> Bool {
        if authInfo == nil {
            return true
        }
        return (authInfo?.isExpired())!
    }
    
    override func checkExpired(_ hiveError: @escaping (_ error: HiveError?) -> Void) {
        if (isExpired()) {
            refreshAccessToken { (error) in
                hiveError(error)
            }
        }
        hiveError(nil)
    }
}
