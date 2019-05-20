import Foundation
import PromiseKit

@objc(AuthHelper)
internal class AuthHelper: NSObject {
    func login(_ authenticator: Authenticator) -> Promise<AuthToken> {
        let error = HiveError.failue(des: "AuthHelper::login")
        return Promise<AuthToken>(error: error)
    }

    func logout() -> Promise<Bool> {
        let error = HiveError.failue(des: "AuthHelper::logout")
        return Promise<Bool>(error: error)
    }

    func checkExpired() -> Promise<Bool> {
        let error = HiveError.failue(des: "AuthHelper::checkExpired")
        return Promise<Bool>(error: error)
    }

    /*
    func headers() -> [String: Any] {
        let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
        return ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
    }
    */
}
