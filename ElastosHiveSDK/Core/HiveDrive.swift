import Foundation
import PromiseKit

@objc(HiveDrive)
public class HiveDriveHandle: NSObject, HiveResourceItem, HiveDirectoryItem {
    public typealias resourceType = HiveDriveInfo
    public var driveType: DriveType
    public var handleId: String?
    public var lastInfo: HiveDriveInfo

    ///  Creates an instance with the specified `driveType` and `info`.
    ///
    /// - Parameters:
    ///   - driveType: The `DriveType`
    ///   - info: The `HiveDriveInfo` instance
    internal init(_ driveType: DriveType, _ info: HiveDriveInfo) {
        self.driveType = driveType
        self.lastInfo = info
        self.handleId = lastInfo.driveId
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

    /// Latst update for HiveDrive subclasses
    ///
    /// - Returns: Returns the latest update information for the subclasses
    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveHandle.resourceType>())
    }

    /// Latst update for HiveDrive subclasses
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
}
