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

/// Configuration for the ElastosHiveSDK.
/// All app information should match the information in your app portal with Microsoft Accounts or Azure Active Directory.
/// @see https://dev.onedrive.com/README.htm for more information.
public class OAuthEntry {

    /// ClientId for OneDrive registered with Microsoft Account.
    /// @see https://dev.onedrive.com/auth/msa_oauth.htm for registration information.
    let clientId: String

    /// Scopes to be used for OneDrive registered with Microsoft Account.
    /// @see https://dev.onedrive.com/auth/msa_oauth.htm for registration information.
    let scope   : String

    /// Redirect URL for OneDrive.
    /// @see https://dev.onedrive.com/auth/aad_oauth.htm for registration information.
    /// @warning This value must be the same as the RedirectURL provided in the Azure Active Directory portal.
    let redirectURL: String

    /// Create OAuthEntry instance
    ///
    /// - Parameters:
    ///   - clientId: The clientId
    ///   - scope: The scope
    ///   - redirectURL: The redirectURL
    public init(_ clientId: String,  _ scope: String, _ redirectURL: String) {
        self.clientId = clientId
        self.scope = scope
        self.redirectURL = redirectURL
    }
}
