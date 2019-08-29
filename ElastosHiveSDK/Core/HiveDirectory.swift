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

/// The class representing the directory handle to specific remote cloud storage backend.
@objc(HiveDirectory)
public class HiveDirectoryHandle: Result, ResourceItem, FileItem, DirectoryItem {
    
    /// This resourceType refers to `HiveDirectoryInfo`.
    public typealias resourceType = HiveDirectoryInfo

    /// The drive handle to which this file handle belongs
    public var drive: HiveDriveHandle?

    /// The ID of directory handle.
    public var directoryId: String

    /// The full path name of this directory.
    public var pathName: String

    /// The last file infomation that cached in local.
    public var lastInfo: HiveDirectoryInfo?

    internal var authHelper: AuthHelper?

    init(_ info: HiveDirectoryInfo, _ authHelper: AuthHelper) {
        self.lastInfo = info
        self.authHelper = authHelper
        self.directoryId = lastInfo!.attrDic![HiveDirectoryInfo.itemId]!
        self.pathName = ""
    }

    /// Get the full path name of parent directory.
    ///
    /// - Returns: the full path of parent directory
    public func parentPathName() -> String {
        return ""
    }

    /// Get the last remote information about this directory and invoke the delegate
    /// callback of upper application.
    ///
    /// - Returns: The promise of last remote information about this directory.
    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryHandle.resourceType>())
    }

    /// Get the last remote information about this directory and invoke the delegate
    /// callback of upper application.
    ///
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of last remote information about this directory.
    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType> {
        return HivePromise<HiveDirectoryInfo>(error: HiveError.failue(des: "Dummy"))
    }

    /// Create a directory with specific name
    ///
    /// - Parameter withPath: The path name of the directory to create
    /// - Returns: The promise of the created directory handle or exception.
    public func createDirectory(withName: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withName: withName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    /// Create a directory with specific name and invoke the delegate callback of upper
    /// application.
    ///
    /// - Parameter withPath: The path name of the directory to create.
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of the created directory handle or exception.
    public func createDirectory(withName: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        return HivePromise<HiveDirectoryHandle>(error: HiveError.failue(des: "Dummy"))
    }

    /// Acquire a subdirectory handle with specific name.
    ///
    /// - Parameter withPath: The subdirectory name.
    /// - Returns: The promise of the acquired directory handle or exception.
    public func directoryHandle(atName: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atName: atName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    /// Acquire a subdirectory handle with specific name and invoke the delegate
    /// callback of upper application.
    ///
    /// - Parameter withPath: The subdirectory name.
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of the acquired directory handle or exception.
    public func directoryHandle(atName: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        return HivePromise<HiveDirectoryHandle>(error: HiveError.failue(des: "Dummy"))
    }

    /// Create a new file with specific name.
    ///
    /// - Parameter withPath: The path name of file to create
    /// - Returns: The promise of the created file handle or exception
    public func createFile(withName: String) -> HivePromise<HiveFileHandle> {
        return createFile(withName: withName, handleBy: HiveCallback<HiveFileHandle>())
    }

    /// Create a new file with specific name and invoke the delegate callback
    /// of upper application.
    ///
    /// - Parameter withPath: The path name of file to create
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of the created file handle or exception
    public func createFile(withName: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        return HivePromise<HiveFileHandle>(error: HiveError.failue(des: "Dummy"))
    }

    /// Acquire file handle with specific file name.
    ///
    /// - Parameter withPath: The path name of file to acquire
    /// - Returns: The promise of the file handle or exception
    public func fileHandle(atName: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atName: atName, handleBy: HiveCallback<HiveFileHandle>())
    }

    /// Acquire file handle with specific file name and invoke the delegate callback
    /// of upper application.
    ///
    /// - Parameter withPath: The path name of file to acquire
    /// - Parameter handleBy: The delegate callback defined by upper application
    /// - Returns: The promise of the file handle or exception
    public func fileHandle(atName: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        return HivePromise<HiveFileHandle>(error: HiveError.failue(des: "Dummy"))
    }

    /// List children item informations under this directory.
    ///
    /// - Returns: The promise of the list object of children items.
    public func getChildren() -> HivePromise<HiveChildren> {
        return getChildren(handleBy: HiveCallback<HiveChildren>())
    }

    /// List children item informations under this directory and invoke the delegate
    /// callback defined by upper application.
    ///
    /// - Parameter handleBy: The delegate callback defined by upper application
    /// - Returns: The promise of the list object of children items.
    public func getChildren(handleBy: HiveCallback<HiveChildren>) -> HivePromise<HiveChildren> {
        return HivePromise<HiveChildren>(error: HiveError.failue(des: "Dummy"))
    }

    /// Move current directory specified by this handle to the new directory
    /// in same remote cloud strage backend and invoke the delegate callback.
    /// If target path `newPath` is a directory name, then the directory would
    /// move to under the target directory.
    ///
    /// - Parameter newPath: The target path name to move this directory.
    /// - Returns: The promise of result of moving directory.
    public func moveTo(newPath: String) -> HivePromise<Void> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Void>())
    }

    /// Move current directory specified by this handle to the new directory
    /// in same remote cloud strage backend and invoke the delegate callback.
    /// If target path `newPath` is a directory name, then the directory would
    /// move to under the target directory.
    ///
    /// - Parameter newPath: The target path name to move this directory.
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of result of moving directory.
    public func moveTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Dummy"))
    }

    /// Copy current directory specified by this handle to the new target path
    /// in same remote cloud strage backend.
    /// If target path `newPath` is a directory name, then the directory would be
    /// copied to under that target directory.
    ///
    /// - Parameter newPath: The target path name to copy this file.
    /// - Returns: The promise of result of file copying.
    public func copyTo(newPath: String) -> HivePromise<Void> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Void>())
    }

    /// Copy current directory specified by this handle to the new target path
    /// in same remote cloud strage backend.
    /// If target path `newPath` is a directory name, then the directory would be
    /// copied to under that target directory.
    ///
    /// - Parameter newPath: The target path name to copy this file.
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of result of file copying.
    public func copyTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Dummy"))
    }

    /// Delete the directory item from remote cloud storage backend and then invoke
    /// the delegate callback. After deletion, this directory handle would become
    /// invalid and should not be referenced later.
    ///
    /// - Returns: The promise of result for file deletion.
    public func deleteItem() -> HivePromise<Void> {
        return deleteItem(handleBy: HiveCallback<Void>())
    }

    /// Delete the directory item from remote cloud storage backend and then invoke
    /// the delegate callback. After deletion, this directory handle would become
    /// invalid and should not be referenced later.
    ///
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of result for file deletion.
    public func deleteItem(handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Dummy"))
    }
}
