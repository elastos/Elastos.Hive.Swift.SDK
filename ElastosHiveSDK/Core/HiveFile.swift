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
    /// - Returns: Returns `Void` if the move succees, `HiveError` otherwise.
    public func moveTo(newPath: String) -> HivePromise<Void> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Void>())
    }

    /// Current File move to the new path
    ///
    /// - Parameters:
    ///   - newPath: The new path with the file
    ///   - handleBy: The result
    /// - Returns: Returns `Void` if the move succees, `HiveError` otherwise.
    public func moveTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Void>(error: error)
    }

    /// Current file copy to the new path
    ///
    /// - Parameter newPath: The path to copy
    /// - Returns: Returns `Void` if the copy succees, `HiveError` otherwise.
    public func copyTo(newPath: String) -> HivePromise<Void> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Void>())
    }

    /// Current file copy to the new path
    ///
    /// - Parameters:
    ///   - newPath: The path to copy
    ///   - handleBy: The result
    /// - Returns: Returns `Void` if the copy succees, `HiveError` otherwise.
    public func copyTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Void>(error: error)
    }

    /// Delete the current file
    ///
    /// - Returns: Returns `Void` if the delete succees, `HiveError` otherwise.
    public func deleteItem() -> HivePromise<Void> {
        return deleteItem(handleBy: HiveCallback<Void>())
    }

    /// Delete the current file
    ///
    /// - Parameter handleBy: The result
    /// - Returns: Returns `Void` if the delete succees, `HiveError` otherwise.
    public func deleteItem(handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Void>(error: error)
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
    /// - Returns: Returns `Void` if the data commit succeed, `HiveError` otherwise.
    public func commitData() -> HivePromise<Void> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Void>(error: error)
    }

    /// Discard written Data
    public func discardData() {}

    /// Close
    public func close() {}
}
