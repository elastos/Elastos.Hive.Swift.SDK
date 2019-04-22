import Foundation
import Swifter
import Unirest

@inline(__always) private func TAG() -> String { return "OneDriveAuthHelper" }

@objc(OneDriveAuthHelper)
internal class OneDriveAuthHelper: AuthHelper {
    typealias ResponseHandle = (_ respondeJson: Dictionary<String, Any>?, _ error: HiveError?) -> Void
    private var authInfo: AuthInfo?
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
        let params: Dictionary<String, Any> = ["client_id" : clientId ?? "",
                                               "code" : authorCode,
                                               "grant_type" : AUTHORIZATION_CODE,
                                               "redirect_uri" : redirectUrl ?? ""]
        let response: UNIHTTPJsonResponse? = UNIRest.postEntity { (request) in
            request?.url = String(format: BASE_REQURL + "/token")
            request?.headers = ["Content-Type": "application/x-www-form-urlencoded"]
            request?.body = params.queryString.data(using: String.Encoding.utf8)
            }?.asJson(&error)

        guard error == nil else {
            hiveError(.systemError(error: error, jsonDes: response?.body.jsonObject()))
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
        let params: Dictionary<String, Any> = ["client_id": clientId ?? "",
                                               "refresh_token": refreshToken,
                                               "grant_type": REFRESH_TOKEN,
                                               "redirect_uri": redirectUrl ?? "",
                                               "scope": scopStr
        ]
        let response: UNIHTTPJsonResponse? = UNIRest.postEntity { (request) in
            request?.url = String(format: BASE_REQURL + "/token")
            request?.headers = ["Content-Type": "application/x-www-form-urlencoded"]
            request?.body = params.queryString.data(using: String.Encoding.utf8)
            }?.asJson(&error)

        guard error == nil else {
            hiveError(.systemError(error: error, jsonDes: response?.body.jsonObject()))
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
        let keychain = KeychainSwift()
        keychain.set(self.authInfo!.accessToken!, forKey: ACCESS_TOKEN)
        hiveError(nil)
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
    }
}
