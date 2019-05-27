import Foundation
import PromiseKit

@objc(AuthHelper)
internal class AuthHelper: NSObject {
    func login(_ authenticator: Authenticator) -> Bool? {
        return nil
    }

    func logout() -> Bool {
        return false
    }

    func checkExpired() -> HivePromise<Bool> {
        let error = HiveError.failue(des: "AuthHelper::checkExpired")
        return HivePromise<Bool>(error: error)
    }

    /*
    func headers() -> [String: Any] {
        let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
        return ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
    }
    */
}
