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
import PromiseKit

@objc(HiveDirectory)
public class HiveDirectoryHandle: Result, ResourceItem, FileItem, DirectoryItem {
    
    public typealias resourceType = HiveDirectoryInfo
    public var drive: HiveDriveHandle?
    public var directoryId: String
    public var pathName: String
    public var lastInfo: HiveDirectoryInfo?
    internal var authHelper: AuthHelper?

    /// Creates an instance with the specified `info` and `authHelper`.
    ///
    /// - Parameters:
    ///   - info: The `DirectoryInfo` instance
    ///   - authHelper: The `AuthHelper` instance of the subclasses
    init(_ info: HiveDirectoryInfo, _ authHelper: AuthHelper) {
        self.lastInfo = info
        self.authHelper = authHelper
        self.directoryId = lastInfo!.attrDic![HiveDirectoryInfo.itemId]!
        self.pathName = ""
    }

    /// Parent path
    ///
    /// - Returns: Returns the parent path of the subclasses
    public func parentPathName() -> String {
        return ""
    }

    /// Latst update for `HiveDirectory` subclasses
    ///
    /// - Returns: Returns the last update info for the subclasses
    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryHandle.resourceType>())
    }

    /// Latst update for `HiveDirectory` subclasses
    ///
    /// - Parameter handleBy: The result
    /// - Returns: Returns the last update info for the subclasses
    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryInfo>(error: error)
    }

    /// Create a directory
    ///
    /// - Parameter withName: The name with the create directory.
    /// - Returns: Returns a directory for subclassees
    public func createDirectory(withName: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withName: withName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    /// Create a directory
    ///
    /// - Parameters:
    ///   - withName: The name with the create directory
    ///   - handleBy: The result
    /// - Returns: Returns a directory for subclasses
    public func createDirectory(withName: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    /// Request a directory with the current directory
    ///
    /// - Parameter atName: The name with the request directory
    /// - Returns: Returns a directory with the given name for subclassses
    public func directoryHandle(atName: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atName: atName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    /// Request a directory with the current directory
    ///
    /// - Parameters:
    ///   - atName: The name with the request directory
    ///   - handleBy: The result
    /// - Returns: Returns a directory with the given name for subclasses
    public func directoryHandle(atName: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    /// Create a file with the current directory
    ///
    /// - Parameter withName: The name with the create file
    /// - Returns: Returns a file with the given name for subclasses
    public func createFile(withName: String) -> HivePromise<HiveFileHandle> {
        return createFile(withName: withName, handleBy: HiveCallback<HiveFileHandle>())
    }

    /// Create a file with the current directory
    ///
    /// - Parameters:
    ///   - withName: The name with the create file
    ///   - handleBy: The result
    /// - Returns: Returns a file with the given name for subclasses
    public func createFile(withName: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }

    /// Requst a file with the current directory
    ///
    /// - Parameter atName: The name with the request file
    /// - Returns: Returns a file with the given name for subclasses
    public func fileHandle(atName: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atName: atName, handleBy: HiveCallback<HiveFileHandle>())
    }

    /// Requst a file with the current directory
    ///
    /// - Parameters:
    ///   - atName: The name with the request file
    ///   - handleBy: The result
    /// - Returns: Resturns a file with the given name for subclasses
    public func fileHandle(atName: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }

    /// List for current directory
    ///
    /// - Returns: Returns list for current directory
    public func getChildren() -> HivePromise<HiveChildren> {
        return getChildren(handleBy: HiveCallback<HiveChildren>())
    }

    /// List for current directory
    ///
    /// - Parameter handleBy: The result
    /// - Returns: Resturns children for current directory
    public func getChildren(handleBy: HiveCallback<HiveChildren>) -> HivePromise<HiveChildren> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveChildren>(error: error)
    }

    /// Current directory move to the new path
    ///
    /// - Parameter newPath: The new path with the directory
    /// - Returns: Returns `Void` if the move succees, `HiveError` otherwise.
    public func moveTo(newPath: String) -> HivePromise<Void> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Void>())
    }

    /// Current directory move to the new path
    ///
    /// - Parameters:
    ///   - newPath: The new path with the directory
    ///   - handleBy: The result
    /// - Returns: Returns `Void` if the move succees, `HiveError` otherwise.
    public func moveTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Void>(error: error)
    }

    /// Current directory copy to the new path
    ///
    /// - Parameter newPath: The new path to copy
    /// - Returns: Returns `Void` if the copy succees, `HiveError` otherwise.
    public func copyTo(newPath: String) -> HivePromise<Void> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Void>())
    }

    /// Current directory copy to the new path
    ///
    /// - Parameters:
    ///   - newPath: The new path to copy
    ///   - handleBy: The result
    /// - Returns: Returns `Void` if the copy succees, `HiveError` otherwise.
    public func copyTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Void>(error: error)
    }

    /// Delete the current directory
    ///
    /// - Returns: Returns `Void` if the delete succees, `HiveError` otherwise.
    public func deleteItem() -> HivePromise<Void> {
        return deleteItem(handleBy: HiveCallback<Void>())
    }

    /// Delete the current directory
    ///
    /// - Parameter handleBy: The result
    /// - Returns: Returns `Void` if the delete succees, `HiveError` otherwise.
    public func deleteItem(handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Void>(error: error)
    }

}
