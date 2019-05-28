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
}
