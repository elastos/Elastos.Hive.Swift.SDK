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

@objc(HiveFile)
public class HiveFileHandle: Result, ResourceItem, FileItem {

    public typealias resourceType = HiveFileInfo
    public var drive: HiveDriveHandle?
    public var fileId: String
    public var pathName: String
    public var lastInfo: HiveFileInfo?

    var authHelper: AuthHelper

    /// Creates an instance with the specified `info` and `authHelper`.
    ///
    /// - Parameters:
    ///   - info: The `HiveFileInfo` instance.
    ///   - authHelper: The `AuthHelper` instance
    init(_ info: HiveFileInfo, _ authHelper: AuthHelper) {
        self.lastInfo = info
        self.authHelper = authHelper
        self.fileId = info.attrDic![HiveFileInfo.itemId]!
        self.pathName = ""
    }
    
    /// Parent path
    ///
    /// - Returns: Returns the parent path of the subclasses
    public func parentPathName() -> String {
        return ""
    }

    /// Latst update for `HiveFile` subclasses
    ///
    /// - Returns: Returns the parent path of the subclasses
    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileHandle.resourceType>())
    }

    /// Latst update for `HiveFile` subclasses
    ///
    /// - Parameter handleBy: The result
    /// - Returns: Returns the parent path of the subclasses
    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileInfo>(error: error)
    }

    /// Current File move to new path
    ///
    /// - Parameter newPath: The new path with the file
    /// - Returns: Returns `HiveVoid` if the move succees, `HiveError` otherwise.
    public func moveTo(newPath: String) -> HivePromise<HiveVoid> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<HiveVoid>())
    }

    /// Current File move to the new path
    ///
    /// - Parameters:
    ///   - newPath: The new path with the file
    ///   - handleBy: The result
    /// - Returns: Returns `HiveVoid` if the move succees, `HiveError` otherwise.
    public func moveTo(newPath: String, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }

    /// Current file copy to the new path
    ///
    /// - Parameter newPath: The path to copy
    /// - Returns: Returns `HiveVoid` if the copy succees, `HiveError` otherwise.
    public func copyTo(newPath: String) -> HivePromise<HiveVoid> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<HiveVoid>())
    }

    /// Current file copy to the new path
    ///
    /// - Parameters:
    ///   - newPath: The path to copy
    ///   - handleBy: The result
    /// - Returns: Returns `HiveVoid` if the copy succees, `HiveError` otherwise.
    public func copyTo(newPath: String, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }

    /// Delete the current file
    ///
    /// - Returns: Returns `HiveVoid` if the delete succees, `HiveError` otherwise.
    public func deleteItem() -> HivePromise<HiveVoid> {
        return deleteItem(handleBy: HiveCallback<HiveVoid>())
    }

    /// Delete the current file
    ///
    /// - Parameter handleBy: The result
    /// - Returns: Returns `HiveVoid` if the delete succees, `HiveError` otherwise.
    public func deleteItem(handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }

    /// Read data of specified length in sequence
    ///
    /// - Parameter length: Length of each read
    /// - Returns: Returns data of a given length
    public func readData(_ length: Int) -> HivePromise<Data> {
        return readData(length, handleBy: HiveCallback<Data>())
    }

    /// Read data of specified length in sequence
    ///
    /// - Parameters:
    ///   - length: Length of each read
    ///   - handleBy: The result
    /// - Returns: Returns data of a given length
    public func readData(_ length: Int, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Data>(error: error)
    }

    /// Read data of specified length form the specified position
    ///
    /// - Parameters:
    ///   - length: Length of specified read
    ///   - position: Start reading position
    /// - Returns: Returns the specified length of the specified location
    public func readData(_ length: Int, _ position: UInt64) -> HivePromise<Data> {
        return readData(length, position, handleBy: HiveCallback<Data>())
    }

    /// Read data of specified length form the specified position
    ///
    /// - Parameters:
    ///   - length: Length of specified read
    ///   - position: Start reading position
    ///   - handleBy: The result
    /// - Returns: Returns the specified length of the specified location
    public func readData(_ length: Int, _ position: UInt64, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Data>(error: error)
    }

    /// Writes local caches in sequence
    ///
    /// - Parameter withData: The data to be written
    /// - Returns: The length of write data
    public func writeData(withData: Data) -> HivePromise<Int32> {
        return writeData(withData: withData, handleBy: HiveCallback<Int32>())
    }

    /// Writes local caches in sequence
    ///
    /// - Parameters:
    ///   - withData: The data to be written
    ///   - handleBy: The result
    /// - Returns: The length of write data
    public func writeData(withData: Data, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Int32>(error: error)
    }

    /// Writes local caches in sequence in the specified position
    ///
    /// - Parameters:
    ///   - withData: The data to be written
    ///   - position: Start writing position
    /// - Returns: The length of write data
    public func writeData(withData: Data, _ position: UInt64) -> HivePromise<Int32> {
        return writeData(withData: withData, position, handleBy: HiveCallback<Int32>())
    }

    /// Writes local caches in sequence in the specified position
    ///
    /// - Parameters:
    ///   - withData: The data to be written
    ///   - position: Start writing position
    ///   - handleBy: The result
    /// - Returns: The length of write data
    public func writeData(withData: Data, _ position: UInt64, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Int32>(error: error)
    }

    ///  Submit data to the remote cloud storage.
    ///
    /// - Returns: Returns `HiveVoid` if the data commit succeed, `HiveError` otherwise.
    public func commitData() -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }

    /// Discard written Data
    public func discardData() {}

    /// Close
    public func close() {}
}
