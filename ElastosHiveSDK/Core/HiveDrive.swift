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

/// The class representing the handle of drive to remote cloud storage service,
/// which currently support `OneDrive` and `Hive IPFS`.
@objc(HiveDrive)
public class HiveDriveHandle: Result, ResourceItem, DirectoryItem {

    /// This resourceType refers to `HiveDriveInfo`.
    public typealias resourceType = HiveDriveInfo

    /// The type name of this drive.
    public var driveType: DriveType

    /// The drive Id of this drive handle.
    public var handleId: String?

    /// The last drive infomation that cached in local device.
    public var lastInfo: HiveDriveInfo

    internal init(_ driveType: DriveType, _ info: HiveDriveInfo) {
        self.driveType = driveType
        self.lastInfo = info
        self.handleId = lastInfo.attrDic![HiveDriveInfo.driveId]
    }

    /// Acquire root directory handle of this drive.
    /// - Returns: The promise of the root directory handle.
    public func rootDirectoryHandle() -> HivePromise<HiveDirectoryHandle> {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    /// Acquire root directory handle of this drive and invoke the delegate callback
    /// defined by upper application.
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of the root directory handle.
    public func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        return HivePromise<HiveDirectoryHandle>(error: HiveError.failue(des: "Dummy"))
    }

    /// Get the last remote information about this drive handle.
    ///
    /// - Returns: The promise of last remote information about this drive or exception.
    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveHandle.resourceType>())
    }

    /// Get the last remote information about this drive handle and invoke the
    /// delegate callback of upper application.
    ///
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of last remote information about this drive or exception.
    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType> {
        return HivePromise<resourceType>(error: HiveError.failue(des: "Dummy"))
    }

    /// Create a directory with specific path name.
    ///
    /// - Parameter withPath: The path name of the directory to create.
    /// - Returns: The promise of the created directory handle or exception.
    public func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    /// Create a directory with specific path name and invoke the delegate callback of upper
    /// application.
    ///
    /// - Parameter withPath: The path name of the directory to create.
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of the created directory handle or exception.
    public func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        return HivePromise<HiveDirectoryHandle>(error: HiveError.failue(des: "Dummy"))
    }

    /// Acquire a directory handle with specific path name.
    ///
    /// - Parameter withPath: The directory path name.
    /// - Returns: The promise of acquired directory handle or exception.
    public func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    /// Acquire a directory handle with specific path name and invoke the delegate
    /// callback of upper application.
    ///
    /// - Parameter withPath: The directory path name.
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of the acquired directory handle or exception.
    public func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        return HivePromise<HiveDirectoryHandle>(error: HiveError.failue(des: "Dummy"))
    }

    /// Create a new file with specific file name.
    ///
    /// - Parameter withPath: The path name of file to create
    /// - Returns: The promise of the created file handle or exception.
    public func createFile(withPath: String) -> HivePromise<HiveFileHandle> {
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    /// Create a new file with specific file name and invoke the delegate callback
    /// of upper application.
    ///
    /// - Parameter withPath: The path name of file to create
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of the created file handle or exception.
    public func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        return HivePromise<HiveFileHandle>(error: HiveError.failue(des: "Dummy"))
    }

    /// Acquire file handle with specific file name.
    ///
    /// - Parameter withPath: The path name of file to create
    /// - Returns: The promise of the file handle or exception.
    public func fileHandle(atPath: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    /// Acquire file handle with specific file name and invoke the delegate callback
    /// of upper application.
    ///
    /// - Parameter withPath: The path name of file to create
    /// - Parameter handleBy: The delegate callback defined by upper application
    /// - Returns: The promise of the file handle or exception.
    public func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        return HivePromise<HiveFileHandle>(error: HiveError.failue(des: "Dummy"))
    }

    /// Acquire information of item (directory or file) with specific name.
    ///
    /// - Parameter path: The path name of file or directory item
    /// - Returns: The promise of the item info or exception.
    public func getItemInfo(_ path: String) -> HivePromise<HiveItemInfo> {
        return getItemInfo(path, handleBy: HiveCallback<HiveItemInfo>())
    }

    /// Acquire information of item (directory or file) with specific name and invoke
    /// the delegate callback defined by upper application.
    ///
    /// - Parameter path: The path name of file or directory item
    /// - Parameter handleBy: The delegate callback defined by upper application
    /// - Returns: The promise of the item info or exception.
    public func getItemInfo(_ path: String, handleBy: HiveCallback<HiveItemInfo>) -> HivePromise<HiveItemInfo>{
        return HivePromise<HiveItemInfo>(error: HiveError.failue(des: "Dummy"))
    }
}
