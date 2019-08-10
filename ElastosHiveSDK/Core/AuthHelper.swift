/*
 * Copyright (c) 2019 Elastos Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation

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
