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

public typealias HivePromise = Promise

/// The class representing the handle of specific client to consume remote
/// cloud storage service, which currently includes `OneDrive` and `Hive IPFS`.
@objc(HiveClient)
public class HiveClientHandle: Result, ResourceItem{

    /// This resourceType refers to `HiveClientInfo`.
    public typealias resourceType = HiveClientInfo

    /// The type of storage drive with which this client is connecting.
    public let driveType: DriveType

    /// The ID of this client handle.
    public var handleId: String?

    /// The last client infomation that cached in local device.
    public var lastInfo: HiveClientInfo?

    internal init(_ driveType: DriveType) {
        self.driveType = driveType
    }

    /// Create a singleton instance of client handle to the specific backend
    /// of cloud storage service.
    /// Each type of storage service only can have a singleton instance of client
    /// handle.
    /// - Parameter param: The parameters used to create client singleton, and
    ///   should be the inherited object of `OneDriveParameter` and `IPFSParameter`
    ///   currently.
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

    /// Acquire a singleton instance of client handle with specific drive type.
    /// This function should be called in the following context after calling
    /// `createInstace` API. Otherwise, it would return the value of`nil`.
    ///
    /// - Parameter type: The drive type used to get client instance.
    /// - Returns: A valid singleton instance of client handle, or `nil` if
    /// `createInstance` has not been called.
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

    /// Login into the remote cloud storage service with user's authorization.
    /// With client instance handle, developers should call this method to acquire
    /// user's authorization at first. Therefore, the other methods would be allowed
    /// to call under the permission.
    ///
    /// - Parameter Authenticator: The implementation class implemented delegated
    ///             by upper application to handle authorization and authentication
    /// - Throws:  `HiveError`
    public func login(_ authenticator: Authenticator) throws {}

    /// Logout from remote cloud storage service. All authorization data cached
    /// local would be deleted and all derived instances of this client, such as
    /// drive handle and directory as well as file handles would become invalid.
    ///
    /// - Throws: `HiveError`
    public func logout() throws {}

    /// Get the last remote information about this client handle.
    ///
    /// - Returns: Returns the latest update information for the subclasses
    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<resourceType>())
    }

    /// Get the last remote information about this client handle and invoke the
    /// delegate callback of upper application.
    ///
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of last remote information about this client.
    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<resourceType>(error: error)
    }

    /// Acquire the default drive handle of this client, which is the singleton
    /// instance of drive handle.
    ///
    /// - Returns: Returns singleton instance for subclasses
    /// - Returns: The promise of the default drive handle.
    public func defaultDriveHandle() -> HivePromise<HiveDriveHandle> {
        return defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>())
    }

    /// Acquire the default drive handle of this client and invoke the delegate
    /// callback defined by upper application.
    ///
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of the default drive handle.
    public func defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>) -> HivePromise<HiveDriveHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDriveHandle>(error: error)
    }
}
