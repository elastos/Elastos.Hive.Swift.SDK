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

/// The class representing the file handle to specific remote cloud storage backend.
@objc(HiveFile)
public class HiveFileHandle: Result, ResourceItem, FileItem {

    /// This resourceType refers to `HiveFileInfo`
    public typealias resourceType = HiveFileInfo

    /// The drive handle to which this file handle belongs
    public var drive: HiveDriveHandle?

    /// The ID of this file handle.
    public var fileId: String

    /// The full path name of this file.
    public var pathName: String

    /// The last file infomation that cached in local.
    public var lastInfo: HiveFileInfo?

    var authHelper: AuthHelper

    init(_ info: HiveFileInfo, _ authHelper: AuthHelper) {
        self.lastInfo = info
        self.authHelper = authHelper
        self.fileId = info.attrDic![HiveFileInfo.itemId]!
        self.pathName = ""
    }
    
    /// Get the full path name of parent directory.
    ///
    /// - Returns: the full path of parent directory
    public func parentPathName() -> String {
        return ""
    }

    /// Get the last remote information about this file.
    ///
    /// - Returns: The promise of last remote information about this file.
    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileHandle.resourceType>())
    }

    /// Get the last remote information about this file and invoke the delegate
    /// callback of upper application.
    ///
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of last remote information about this file.
    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType> {
        return HivePromise<HiveFileInfo>(error: HiveError.failue(des: "Dummy"))
    }

    /// Move the current file specified by this handle to the new directory
    /// in same remote cloud strage backend.
    /// If target path `newPath` is a directory name, then the file would
    /// move to under the target directory. If the target path is a file path name,
    /// then current file would move to be the file with target path `newPath`.
    ///
    /// - Parameter newPath: The target path name to move this file.
    /// - Returns: The promise of result of file moving.
    public func moveTo(newPath: String) -> HivePromise<Void> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Void>())
    }

    /// Move the current file specified by this handle to the new directory
    /// in same remote cloud strage backend and invoke the delegate callback.
    /// If target path `newPath` is a directory name, then the file would
    /// move to under the target directory. If the target path is a file path name,
    /// then current file would move to be the file with target path `newPath`.
    ///
    /// - Parameter newPath: The target path name to move this file.
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of result of file moving.
    public func moveTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Dummy"))
    }

    /// Copy the current file specified by this handle to the new target path
    /// in same remote cloud strage backend.
    /// If target path `newPath` is a directory name, then the file would be
    /// copied to under that target directory. If target path is a file path name,
    /// then current file would be copied to be the file with target path `newPath`.
    ///
    /// - Parameter newPath: The target path name to copy this file.
    /// - Returns: The promise of result of file copying.
    public func copyTo(newPath: String) -> HivePromise<Void> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Void>())
    }

    /// Copy the current file specified by this handle to the new target path
    /// in same remote cloud strage backend and invoke the delegate callback.
    /// If target path `newPath` is a directory name, then the file would be
    /// copied to under that target directory. If target path is a file path name,
    /// then current file would be copied to be the file with target path `newPath`.
    ///
    /// - Parameter newPath: The target path name to copy this file.
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of result of file copying.
    public func copyTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Dummy"))
    }

    /// Delete the file item from remote cloud storage backend. After deletion,
    /// this file handle would become invalid and should not be referenced later.
    ///
    /// - Returns: The promise of result for file deletion.
    public func deleteItem() -> HivePromise<Void> {
        return deleteItem(handleBy: HiveCallback<Void>())
    }

    /// Delete the file item from remote cloud storage backend and then invoke
    /// the delegate callback. After deletion, this file handle would become
    /// invalid and should not be referenced later.
    ///
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of result for file deletion.
    public func deleteItem(handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Dummy"))
    }

    /// Read the specific length of data from this file.
    ///
    /// - Parameter length: The given length of data to read.
    /// - Returns: The promise of data read.
    public func readData(_ length: Int) -> HivePromise<Data> {
        return readData(length, handleBy: HiveCallback<Data>())
    }

    /// Read the specific length of data from this file and invoke the delegate
    /// callback defined by upper application.
    ///
    /// - Parameter length: The given length of data to read.
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of data read.
    public func readData(_ length: Int, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        return HivePromise<Data>(error: HiveError.failue(des: "Dummy"))
    }

    /// Read the specific length of data with offset position from this file.
    ///
    /// - Parameter length: The given length of data to read.
    /// - Parameter position: The offset position from which to read data.
    /// - Returns: The promise of data read.
    public func readData(_ length: Int, _ position: UInt64) -> HivePromise<Data> {
        return readData(length, position, handleBy: HiveCallback<Data>())
    }

    /// Read the specific length of data with offset position from this file.
    ///
    /// - Parameter length: The given length of data to read.
    /// - Parameter position: The offset position from which to read data.
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of data read.
    public func readData(_ length: Int, _ position: UInt64, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        return HivePromise<Data>(error: HiveError.failue(des: "Dummy"))
    }

    /// Write specific data to this file.
    /// To be noticed that the data just has been written into local file.
    /// After finishing writing, `commitData` method should be called so
    /// as to synchrize the written data into remote cloud storage.
    /// - Parameter withData: The data to be written into file.
    /// - Returns: The promise of length value of written data.
    public func writeData(withData: Data) -> HivePromise<Int32> {
        return writeData(withData: withData, handleBy: HiveCallback<Int32>())
    }

    /// Write specific data to this file.
    /// To be noticed that the data just has been written into local file.
    /// After finishing writing, `commitData` method should be called so
    /// as to synchrize the written data into remote cloud storage.
    ///
    /// - Parameter withData: The data to be written into file.
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of length value of written data.
    public func writeData(withData: Data, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        return HivePromise<Int32>(error: HiveError.failue(des: "Dummy"))
    }

    /// Write specific data with start position to this file.
    /// To be noticed that the data just has been written into local file.
    /// After finishing writing, `commitData` method should be called so
    /// as to synchrize the written data into remote cloud storage.
    ///
    /// - Parameter withData: The data to be written into file.
    /// - Parameter position: The position of data from which to read.
    /// - Returns: The promise of length value of written data.
    public func writeData(withData: Data, _ position: UInt64) -> HivePromise<Int32> {
        return writeData(withData: withData, position, handleBy: HiveCallback<Int32>())
    }

    /// Write specific data with start position to this file.
    /// To be noticed that the data just has been written into local file.
    /// After finishing writing, `commitData` method should be called so
    /// as to synchrize the written data into remote cloud storage.
    ///
    /// - Parameter withData: The data to be written into file.
    /// - Parameter position: The position of data from which to read.
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of length value of written data.
    public func writeData(withData: Data, _ position: UInt64, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        return HivePromise<Int32>(error: HiveError.failue(des: "Dummy"))
    }

    /// Commit the written file to sync it to remote cloud storage backend.
    ///
    /// - Returns: The promise of result of file moving.
    public func commitData() -> HivePromise<Void> {
        return commitData(handleBy: HiveCallback())
    }

    /// Commit the written file to sync it to remote cloud storage backend.
    ///
    /// - Parameter handleBy: The delegate callback defined by upper application.
    /// - Returns: The promise of result of file moving.
    public func commitData(handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Dummy"))
    }

    /// Discard all written data in local, which means cancel all result of
    /// `writeData` method.
    public func discardData() {}
}
