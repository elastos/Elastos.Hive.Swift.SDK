import Foundation
import PromiseKit

@objc(HiveFile)
public class HiveFileHandle: NSObject, HiveResourceItem, HiveFileItem {
    public typealias resourceType = HiveFileInfo
    public var drive: HiveDriveHandle?
    public var fileId: String
    public var pathName: String
    public var lastInfo: HiveFileInfo?
    var authHelper: AuthHelper?

    /// Creates an instance with the specified `info` and `authHelper`.
    ///
    /// - Parameters:
    ///   - info: The `HiveFileInfo` instance.
    ///   - authHelper: The `AuthHelper` instance
    init(_ info: HiveFileInfo, _ authHelper: AuthHelper) {
        self.lastInfo = info
        self.authHelper = authHelper
        self.fileId = lastInfo!.fileId
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
    /// - Returns: Returns `true` if the move succees, `false` otherwise.
    public func moveTo(newPath: String) -> HivePromise<Bool> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    /// Current File move to the new path
    ///
    /// - Parameters:
    ///   - newPath: The new path with the file
    ///   - handleBy: The result
    /// - Returns: Returns `true` if the move succees, `false` otherwise.
    public func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    /// Current file copy to the new path
    ///
    /// - Parameter newPath: The path to copy
    /// - Returns: Returns `true` if the copy succees, `false` otherwise.
    public func copyTo(newPath: String) -> HivePromise<Bool> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    /// Current file copy to the new path
    ///
    /// - Parameters:
    ///   - newPath: The path to copy
    ///   - handleBy: The result
    /// - Returns: Returns `true` if the copy succees, `false` otherwise.
    public func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    /// Delete the current file
    ///
    /// - Returns: Returns `true` if the delete succees, `false` otherwise.
    public func deleteItem() -> HivePromise<Bool> {
        return deleteItem(handleBy: HiveCallback<Bool>())
    }

    /// Delete the current file
    ///
    /// - Parameter handleBy: The result
    /// - Returns: Returns `true` if the delete succees, `false` otherwise.
    public func deleteItem(handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    /// Read file content
    ///
    /// - Returns: Returns file content
    public func readData() -> HivePromise<String> {
        return readData(handleBy: HiveCallback<String>())
    }

    /// Read file content
    ///
    /// - Parameter handleBy: The result
    /// - Returns: Returns file content
    public func readData(handleBy: HiveCallback<String>) -> HivePromise<String> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<String>(error: error)
    }

    /// Maximum Write 4MB
    ///
    /// - Parameter withData: The data with write
    /// - Returns: Returns `true` if the write succees, `false` otherwise.
    public func writeData(withData: Data) -> HivePromise<Bool> {
        return writeData(withData: withData, handleBy: HiveCallback<Bool>())
    }

    /// Maximum Write 4MB
    ///
    /// - Parameters:
    ///   - withData: The data with write
    ///   - handleBy: The result
    /// - Returns: Returns `true` if the write succees, `false` otherwise.
    public func writeData(withData: Data, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    /// Write large data
    ///
    /// - Parameter withPath: The file path
    /// - Returns: Returns `true` if the write succees, `false` otherwise.
    public func writeDataWithLarge(withPath: String) -> HivePromise<Bool> {
        return writeDataWithLarge(withPath: withPath, handleBy: HiveCallback<Bool>())
    }

    /// Write large data
    ///
    /// - Parameters:
    ///   - withPath: The file path
    ///   - handleBy: The result
    /// - Returns: Returns `true` if the write succees, `false` otherwise.
    public func writeDataWithLarge(withPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }
    
    /// Close
    public func close() {
        // TODO
    }
}
