import Foundation
import PromiseKit

@objc(AuthHelper)
internal class AuthHelper: NSObject {
    func loginAsync(_ authenticator: Authenticator) -> HivePromise<HiveVoid> {
        return loginAsync(authenticator, handleBy: HiveCallback<HiveVoid>())
    }

    func loginAsync(_ authenticator: Authenticator, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }

    func logoutAsync() -> HivePromise<HiveVoid> {
        return logoutAsync(handleBy: HiveCallback<HiveVoid>())
    }

    func logoutAsync(handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }

    func checkExpired() -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }
}
