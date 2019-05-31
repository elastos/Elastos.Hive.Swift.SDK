import Foundation
import PromiseKit

@objc(AuthHelper)
internal class AuthHelper: NSObject {
    func loginAsync(_ authenticator: Authenticator) -> HivePromise<Bool> {
        return loginAsync(authenticator, handleBy: HiveCallback<Bool>())
    }

    func loginAsync(_ authenticator: Authenticator, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    func logoutAsync() -> HivePromise<Bool> {
        return logoutAsync(handleBy: HiveCallback<Bool>())
    }

    func logoutAsync(handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    func checkExpired() -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }
}
