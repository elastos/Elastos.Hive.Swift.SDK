import Foundation
import Unirest

@inline(__always) private func TAG() -> String { return "OneDriveAuthHelper" }

@objc(OneDriveAuthHelper)
internal class OneDriveAuthHelper: AuthHelper {
    private var authInfo: AuthInfo?
    private var clientId: String
    private var scopes: String
    private var redirectUrl: String
    private var authCode: String?

    init(_ clientId: String, _ scopes: Array<String>, _ redirectUrl: String) {
        self.clientId = clientId
        self.scopes = scopes.joined(separator: " ")
        self.redirectUrl = redirectUrl
    }

    override func login(_ authenticator: Authenticator) throws {
        if !hasLogin() {
            do {
                let authorCode: String = try acquireAuthorizationCode(authenticator)
                try requestAccessToken(authorCode)
                authCode = nil
            } catch {
                // TODO
            }
        }
    }

    private func acquireAuthorizationCode(_ authenticator: Authenticator) throws -> String {
        let requestUrl = String(format: "%s/authorize?client_id=%s&scope=%s&response_type=code&redirect_uri=%s", BASE_REQURL, clientId, redirectUrl)
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
        let server: SimpleAuthServer = SimpleAuthServer(semaphore)

        //requestUrl.replacingCharacters(in: RangeExpression(""), with: "%20")
        server.startRun(44316)

        authenticator.requestAuthentication(requestUrl)
        semaphore.wait()

        let authCode: String = server.getAuthorizationCode()
        Log.d(TAG(), "Acquired authorization Code: %s", authCode)

        server.stop()

        return authCode
    }

    private func requestAccessToken(_ authorCode: String) throws {
        let requestBody = String(format:"client_id=%s&redirect_url=%s&code=%s&grant_type=authorization_code", clientId, redirectUrl, authorCode)
        let response: UNIHTTPJsonResponse? = UNIRest.postEntity { (request) in
            request?.url = String(format: "%s/token", BASE_REQURL)
            request?.headers["Content-Type"] = "application/x-www-form-urlencoded"
            request?.body = Data(base64Encoded: requestBody)
        }?.asJson()

        guard response != nil else {
            // TODO
            // throw HiveError()
            return
        }

        let jsonObject: [String: Any] = response!.body.object as! [String: Any]
        let authInfo = AuthInfo()
        authInfo.accessToken = jsonObject["access_token"] as! String?
        authInfo.refreshToken = jsonObject["refresh_token"] as! String?
        authInfo.expiredIn = jsonObject["expired_in"] as! Int64?
        authInfo.scopes = jsonObject["scopes"] as! String?
        authInfo.expiredTime = HelperMethods.getExpireTime(time: authInfo.expiredIn!)

        let keychain = KeychainSwift()
        keychain.set(authInfo.accessToken!, forKey:"access_token")
    }

    private func redeemAccessToken(_ errorHandler: @escaping (_ error: HiveError?) -> Void) throws {
        let requestBody = String(format:"client_id=%s&redirect_url=%s&refresh_token=%s&grant_type=refresh_token", clientId, redirectUrl, authInfo!.refreshToken!)

        UNIRest.postEntity { (request) in
            request?.url = String(format: "%s/token", BASE_REQURL)
            request?.headers["Content-Type"] = "application/x-www-form-urlencoded"
            request?.body = Data(base64Encoded: requestBody)
        }?.asJsonAsync({ (response, error) in
            guard response != nil else {
                //TODO
                //errorHandler(HiveError())
                return
            }

            let jsonObject: [String: Any] = response!.body.object as! [String: Any]
            self.authInfo!.accessToken = jsonObject["access_token"] as! String?
            let keychain = KeychainSwift()
            keychain.set(self.authInfo!.accessToken!, forKey:"access_token")
            errorHandler(nil)
        })
    }

    private func hasLogin() -> Bool {
        return authInfo != nil;
    }
    
    private func isExpired() -> Bool {
        return (authInfo?.isExpired())!
    }

    override func checkExpired(_ errorHandler: @escaping (_ error: HiveError?) -> Void) throws {
        guard !isExpired() else {
            try redeemAccessToken() { (_internalError) in
                errorHandler(_internalError)
            }

            return
        }
    }

    override func getAuthInfo() -> AuthInfo? {
        return authInfo
    }
}
