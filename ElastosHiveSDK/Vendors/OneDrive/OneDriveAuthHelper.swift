import Foundation
import Swifter
import Unirest

@objc(OneDriveAuthHelper)
class OneDriveAuthHelper: AuthHelper {
    typealias ResponseHandle = (_ respondeJson: Dictionary<String, Any>?, _ error: HiveError?) -> Void
    private var authInfo: AuthInfo?
    private var appId: String
    private var scopes: String
    private var redirectUrl: String
    private var authCode: String?
    let server = SimpleAuthServer()

    init(_ appId: String, _ scopes: Array<String>, _ redirectUrl: String) {
        self.appId = appId
        self.scopes = scopes.joined(separator: " ")
        self.redirectUrl = redirectUrl
    }

    func login(_ hiveError: @escaping (_ error: HiveError?) -> Void) {
        if (!hasLogin()) {
            acquireAuthorizationCode { (authCode, error) in
                guard error == nil else {
                    hiveError(error)
                    return
                }
                self.authCode = authCode
                self.requestAccessToken(authCode!, { (error) in
                    hiveError(error)
                })
                self.authCode = nil
                self.server.stop()
            }
        }
    }

    private func acquireAuthorizationCode(_ authHandle: @escaping (_ authCode: String?, _ error: HiveError?) -> Void) {
        server.startRun(44316)
        server.getAuthorizationCode { (authCode, error) in
            authHandle(authCode, error)
        }
    }

    private func requestAccessToken(_ authorCode: String, _ hiveError: @escaping (_ error: HiveError?) -> Void) {

        var error: NSError?
        let requestBody = String(format:"client_id=\(appId)&redirect_url=\(redirectUrl)&code=\(authorCode)&grant_type=\(AUTHORIZATION_CODE)")
        let response: UNIHTTPJsonResponse? = UNIRest.postEntity { (request) in
            request?.url = String(format: BASE_REQURL + "/token")
            request?.headers = ["Content-Type": "application/x-www-form-urlencoded"]
            request?.body = requestBody.data(using: String.Encoding.utf8)
            }?.asJson(&error)

        guard error == nil else {
            hiveError(.systemError(error: error))
            return
        }
        guard response?.code == 200 else {
            hiveError(.jsonFailue(des: (response?.body.jsonObject())!))
            return
        }
            self.authInfo = AuthInfo()
            self.authInfo?.accessToken = (response?.body.jsonObject()[ACCESS_TOKEN] as! String)
            self.authInfo?.refreshToken = (response?.body.jsonObject()[REFRESH_TOKEN] as! String)
            self.authInfo?.expiredIn = (response?.body.jsonObject()[EXPIRES_IN] as! Int64)
            self.authInfo?.scopes = (response?.body.jsonObject()[SCOPE] as! String)
        let expireTime = HelperMethods.getExpireTime(time: self.authInfo!.expiredIn!)
            self.authInfo?.expiredTime = expireTime

            // todo  save to keychain: access_token & refresh_token & expire_time
        let accesstoken: String = self.authInfo!.accessToken! // todo  save to keychain
            let keychain = KeychainSwift()
            keychain.set(accesstoken, forKey: ACCESS_TOKEN)
            hiveError(nil)
    }
    
    private func refreshAccessToken(_ hiveError: @escaping (_ error: HiveError?) -> Void) {

        var error: NSError?
        let scops = ["Files.ReadWrite","offline_access"]
        let scopStr = scops.joined(separator: " ")
        let refreshToken: String = authInfo!.refreshToken!
        let requestBody = String(format:"client_id=\(appId)&redirect_url=\(redirectUrl)&refresh_token=\(refreshToken)&grant_type=\(AUTHORIZATION_CODE)&scope=\(scopStr)")
        let response: UNIHTTPJsonResponse? = UNIRest.postEntity { (request) in
            request?.url = String(format: BASE_REQURL + "/token")
            request?.headers = ["Content-Type": "application/x-www-form-urlencoded"]
            request?.body = requestBody.data(using: String.Encoding.utf8)
            }?.asJson(&error)

        guard error == nil else {
            hiveError(.systemError(error: error))
            return
        }
        guard response?.code == 200 else {
            hiveError(.jsonFailue(des: (response?.body.jsonObject())!))
            return
        }
            self.authInfo?.accessToken = (response?.body.jsonObject()[ACCESS_TOKEN] as! String)
            self.authInfo?.refreshToken = (response?.body.jsonObject()[REFRESH_TOKEN] as! String)
            self.authInfo?.expiredIn = (response?.body.jsonObject()[EXPIRES_IN] as! Int64)
            self.authInfo?.scopes = (response?.body.jsonObject()[SCOPE] as! String)
        let expireTime = HelperMethods.getExpireTime(time: self.authInfo!.expiredIn!)
            self.authInfo?.expiredTime = expireTime

            // todo  save to keychain: access_token & refresh_token & expire_time
            let keychain = KeychainSwift()
        keychain.set(self.authInfo!.accessToken!, forKey: ACCESS_TOKEN)
            hiveError(nil)
    }
    
    private func hasLogin() -> Bool {
        return authInfo != nil;
    }
    
    private func isExpired() -> Bool {
        return (authInfo?.isExpired())!
    }
    
    override func checkExpired(_ hiveError: @escaping (_ error: HiveError?) -> Void) {
        if (isExpired()) {
            refreshAccessToken { (error) in
                hiveError(error)
            }
        }
    }
}
