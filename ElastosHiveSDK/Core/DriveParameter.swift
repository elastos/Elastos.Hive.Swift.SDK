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

    /// The cache path
    public var keyStorePath: String = ""

    /*

    /// Creates an instance of the specific `OneDriveParameter` type.
    ///
    /// - Parameters:
    ///   - entry: The OAuthEntry for onedrive
    ///   - storePath: The cache path for onedrive
    /// - Returns:Returns onedrive parameter instance
    public static func createForOneDrive(_ entry: OAuthEntry, _ storePath: String) -> DriveParameter {
        return OneDriveParameter(entry, storePath)
    }

    /// Creates an instance of the specific `IPFSParameter` type.
    ///
    /// - Parameters:
    ///   - entry: The OAuthEntry for ipfs
    ///   - storePath: The cache path for ipfs
    /// - Returns: Returns ipfs parameter instance
    public static func createForIpfsDrive(_ entry: IPFSEntry, _ storePath: String) -> DriveParameter {
        return IPFSParameter(entry, storePath)
    }
   */
    
}
