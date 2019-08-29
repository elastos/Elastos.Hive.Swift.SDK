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

/// An alias global type of `Promise`.
public typealias HivePromise = Promise

/// The class representing the handle of specific client to consume remote
/// cloud storage service, which currently support `OneDrive` and `Hive IPFS`.
@objc(HiveClient)
public class HiveClientHandle: Result, ResourceItem{

    /// HiveClientInfo
    public typealias resourceType = HiveClientInfo

    /// The HiveDrive type
    public let driveType: DriveType

    /// The unique identifier for the user.
    public var handleId: String?

    /// The HiveClient info
    public var lastInfo: HiveClientInfo?

    /// Creates an instance with the specified `driveType`.
    ///
    /// - Parameter driveType: The `DriveType` instance
    internal init(_ driveType: DriveType) {
        self.driveType = driveType
    }

    /// Creates an instance with the specific `OneDriveParameter`,
    /// `DropBoxParameter`, `OwnCloudParameter`, 'IPFSParameter' and 'NativeParameter'.
    ///
    /// - Parameter param: Client singleton type & requred param,
    ///   for example: use a OneDriveParameter will create OneDriveClient singleton
    public static func createInstance(_ param: DriveParameter) {
        let type: DriveType = param.driveType()
        switch type {
        case .nativeStorage:
            NativeClient.createInstance(param as! NativeParameter)
        case .oneDrive:
            OneDriveClient.createInstance(param as! OneDriveParameter)
        case .ownCloud:
            OwnCloudClient.createInstance(param as! OwnCloudParameter)
        case .dropBox:
            DropboxClient.createInstance(param as! DropBoxParameter)
        case .hiveIPFS:
            IPFSClient.createInstance(param as! IPFSParameter)
        }
    }

    /// Returns a spacific HiveClient singleton
    ///
    /// - Parameter type: will returns type
    /// - Returns: return a HiveClient singleton
    public static func sharedInstance(type: DriveType) -> HiveClientHandle? {
        switch type {
        case .nativeStorage:
            return NativeClient.sharedInstance()
        case .oneDrive:
            return OneDriveClient.sharedInstance()
        case .ownCloud:
            return OwnCloudClient.sharedInstance()
        case .dropBox:
            return DropboxClient.sharedInstance()
        case .hiveIPFS:
            return IPFSClient.sharedInstance()
        }
    }

    /// Login with account
    ///
    /// - Parameter Authenticator: authenticator instance,
    ///   implement related delegate for authorization
    /// - Returns:  Returns `Void` if the login succees, `HiveError` otherwise.
    public func login(_ authenticator: Authenticator) throws {}

    /// Logout with account
    ///
    /// - Returns: Returns `Void` if the logout succees, `HiveError` otherwise.
    public func logout() throws {}

    /// Last update for HiveClientHandle subclasses
    ///
    /// - Returns: The promise of last remote information about this client.
    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<resourceType>())
    }

    /// Last update for HiveClientHandle subclasses
    ///
    /// - Parameter handleBy: the result of returns
    /// - Returns: Returns the latest update information for the subclasses
    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType> {
        return HivePromise<resourceType>(error: HiveError.failue(des: "Dummy"))
    }

    /// Creates a default HiveDriveHandle for subclasses
    ///
    /// - Returns: The promise of the default drive handle.
    public func defaultDriveHandle() -> HivePromise<HiveDriveHandle> {
        return defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>())
    }

    /// Creates a default HiveDriveHandle for subclasses
    ///
    /// - Parameter handleBy: the result of returns
    /// - Returns: Returns singleton instance for subclasses
    public func defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>) -> HivePromise<HiveDriveHandle> {
        return HivePromise<HiveDriveHandle>(error: HiveError.failue(des: "Dummy"))
    }
}
