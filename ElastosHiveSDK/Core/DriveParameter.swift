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

@objc(DriveParameter)

/// Configuration Paramsters for the ElastosHiveSDK.
public class DriveParameter: NSObject {

    /// Returns a type, default `oneDrive`
    ///
    /// - Returns: Returns a type, default `oneDrive`
    public func driveType() -> DriveType {
        return DriveType.oneDrive
    }

    /// Creates an instance of the specific `OneDriveParameter` type.
    ///
    /// - Parameters:
    ///   - clientId: ClientId for OneDrive registered with Microsoft Account.
    ///   - scope: Scopes to be used for OneDrive registered with Microsoft Account.
    ///   - redirectUrl: Redirect URL for OneDrive.
    /// - Returns: Returns parameter instance
    public static func createForOneDrive(_ clientId: String, _ scope: String, _ redirectUrl: String) -> DriveParameter {
        return OneDriveParameter(clientId, scope, redirectUrl)
    }

    /// Creates an instance of the specific `IPFSParameter` type.
    ///
    /// - Parameter uid: a unique UID. The UID can be used to identify endpoints in communication.
    /// - Returns: Returns parameter instance.
    public static func createForIpfsDrive(_ entry: IPFSEntry) -> DriveParameter {
        return IPFSParameter(entry)
    }
}
