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

@objc(HiveDrive)
public class HiveDriveHandle: Result, ResourceItem, DirectoryItem {

    /// HiveDriveInfo
    public typealias resourceType = HiveDriveInfo

    /// The HiveDrive type
    public var driveType: DriveType

    /// The drive id
    public var handleId: String?

    /// The HiveDrive info
    public var lastInfo: HiveDriveInfo

    ///  Creates an instance with the specified `driveType` and `info`.
    ///
    /// - Parameters:
    ///   - driveType: The `DriveType`
    ///   - info: The `HiveDriveInfo` instance
    internal init(_ driveType: DriveType, _ info: HiveDriveInfo) {
        self.driveType = driveType
        self.lastInfo = info
        self.handleId = lastInfo.attrDic![HiveDriveInfo.driveId]
    }

    /// Creates a root directory.
    ///
    /// - Returns: Returns a root directory of the subclasses
    public func rootDirectoryHandle() -> HivePromise<HiveDirectoryHandle> {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    /// Creates a root directory.
    ///
    /// - Parameter handleBy: The result of returns
    /// - Returns: Returns a root directory of the subclasses
    public func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    /// Last update for HiveDrive subclasses
    ///
    /// - Returns: Returns the latest update information for the subclasses
    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveHandle.resourceType>())
    }

    /// Last update for HiveDrive subclasses
    ///
    /// - Parameter handleBy: The result of the returns
    /// - Returns: Returns the latest update information for the subclasses
    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<resourceType>(error: error)
    }

    /// Create a directory with a path
    ///
    /// - Parameter withPath: The path of the directory
    /// - Returns: Returns a directory instance
    public func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    /// Create a directory with a path
    ///
    /// - Parameters:
    ///   - withPath: The path of the directory
    ///   - handleBy: The result of the returns
    /// - Returns: Returns a directory instance
    public func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    /// Request a directory with a path
    ///
    /// - Parameter atPath: The path of the directory
    /// - Returns: Returns a directory for the given path of the subclasses
    public func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    /// Request a directory with a path
    ///
    /// - Parameters:
    ///   - atPath: The path
    ///   - handleBy: The result
    /// - Returns: Returns a directory for the given path of the subclasses
    public func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    /// Create a file with a path
    ///
    /// - Parameter withPath: The path
    /// - Returns: Returns a file instance of the subclasses
    public func createFile(withPath: String) -> HivePromise<HiveFileHandle> {
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    /// Create a file with a path
    ///
    /// - Parameters:
    ///   - withPath: The path
    ///   - handleBy: The resutl
    /// - Returns: Returns a file instance of the subclasses
    public func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }

    /// Request a file with a path
    ///
    /// - Parameter atPath: The path
    /// - Returns: Returns a file with for the given path of the subclasses
    public func fileHandle(atPath: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    /// Request a file with a path
    ///
    /// - Parameters:
    ///   - atPath: The path
    ///   - handleBy: The result
    /// - Returns: Returns a file with for the given path of the subclasses
    public func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }


    /// Request itemInfo with a path
    ///
    /// - Parameter path: The path
    /// - Returns: The itemInfo
    public func getItemInfo(_ path: String) -> HivePromise<HiveItemInfo> {
        return getItemInfo(path, handleBy: HiveCallback<HiveItemInfo>())
    }

    /// Request itemInfo with a path
    ///
    /// - Parameters:
    ///   - path: The path
    ///   - handleBy: The result
    /// - Returns: The itemInfo
    public func getItemInfo(_ path: String, handleBy: HiveCallback<HiveItemInfo>) -> HivePromise<HiveItemInfo>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveItemInfo>(error: error)
    }
}
