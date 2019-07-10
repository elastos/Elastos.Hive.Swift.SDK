import Foundation
import PromiseKit

@objc(AuthHelper)
internal class AuthHelper: NSObject {

    /// Login async with authenticator
    ///
    /// - Parameter Authenticator: authenticator instance,
    ///   implement related delegate for authorization
    /// - Returns:  Returns `void` if the login succees, `error` otherwise.
    func loginAsync(_ authenticator: Authenticator) -> HivePromise<HiveVoid> {
        return loginAsync(authenticator, handleBy: HiveCallback<HiveVoid>())
    }
    
    /// Login async with authenticator
    ///
    /// - Parameter Authenticator: authenticator instance,
    ///   implement related delegate for authorization
    /// - Parameter handleBy: The result of returns
    /// - Returns:  Returns `void` if the login succees, `error` otherwise.
    func loginAsync(_ authenticator: Authenticator, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }

    /// logout with account
    ///
    /// - Returns:  Returns `void` if the logout succees, `error` otherwise.
    func logoutAsync() -> HivePromise<HiveVoid> {
        return logoutAsync(handleBy: HiveCallback<HiveVoid>())
    }

    /// logout with account
    ///
    /// - Returns:  Returns `void` if the logout succees, `error` otherwise.
    func logoutAsync(handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }

    /// Check access token isExpired
    /// - Returns:  Returns `void` if expired, `error` otherwise.
    func checkExpired() -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }
}
