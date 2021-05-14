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

public protocol DataStorageProtocol {
    func loadBackupCredential(_ serviceDid: String) -> String?
    
    func loadSignInCredential() -> String?
    
    /// Load access token by serviceDid which can be used for authorization.
    /// - parameter path: serviceDid service did
    /// - returns: access token
    func loadAccessToken(_ serviceDid: String) -> String?

    /// Load access token by provider address which can be used for authorization.
    /// - parameter path: providerAddress provider address to access
    /// - returns: access token
    func loadAccessTokenByAddress(_ providerAddress: String) -> String?

    func storeBackupCredential(_ serviceDid: String, _ credential: String)
    
    func storeSignInCredential(_ credential: String)

    /// Load access token by provider address which can be used for authorization.
    /// - parameters:
    ///   - serviceDid: service did
    ///   - accessToken: access token to be stored
    func storeAccessToken(_ serviceDid: String, _ accessToken: String)

    /// Store access token to data storage by provider address.
    /// - parameters:
    ///   - serviceDid: providerAddress provider address
    ///   - accessToken: access token
    func storeAccessTokenByAddress(_ serviceDid: String, _ accessToken: String)
    
    func clearBackupCredential(_ serviceDid: String)
    func clearSignInCredential()
    func clearAccessToken(_ serviceDid: String)
    func clearAccessTokenByAddress(_ providerAddress: String)
}
