import Foundation
import PromiseKit

@objc(AuthHelper)
internal class AuthHelper: NSObject {

    /// Login async with authenticator
    ///
    /// - Parameter Authenticator: authenticator instance,
    ///   implement related delegate for authorization
    /// - Returns:  Returns `Void` if the login succees, `HiveError` otherwise.
    func loginAsync(_ authenticator: Authenticator) -> HivePromise<Void> {
        return loginAsync(authenticator, handleBy: HiveCallback<Void>())
    }
    
    /// Login async with authenticator
    ///
    /// - Parameter Authenticator: authenticator instance,
    ///   implement related delegate for authorization
    /// - Parameter handleBy: The result of returns
    /// - Returns:  Returns `Void` if the login succees, `HiveError` otherwise.
    func loginAsync(_ authenticator: Authenticator, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Void>(error: error)
    }

    /// logout with account
    ///
    /// - Returns:  Returns `Void` if the logout succees, `HiveError` otherwise.
    func logoutAsync() -> HivePromise<Void> {
        return logoutAsync(handleBy: HiveCallback<Void>())
    }

    /// logout with account
    ///
    /// - Returns:  Returns `Void` if the logout succees, `HiveError` otherwise.
    func logoutAsync(handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Void>(error: error)
    }

    /// Check access token isExpired
    /// - Returns:  Returns `Void` if expired, `HiveError` otherwise.
    func checkExpired() -> HivePromise<Void> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Void>(error: error)
    }
}
