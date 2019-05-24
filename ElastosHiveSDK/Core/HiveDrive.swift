import Foundation
import PromiseKit

@objc(HiveDrive)
public class HiveDriveHandle: NSObject, HiveResourceItem, HiveDirectoryItem {
    public var driveType: DriveType
    public var handleId: String?
    public var lastInfo: HiveDriveInfo?

    internal init(_ driveType: DriveType, _ info: HiveDriveInfo) {
        self.driveType = driveType
    }

    public func rootDirectoryHandle() -> Promise<HiveDirectoryHandle>? {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    public func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>) -> Promise<HiveDirectoryHandle>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveDirectoryHandle>(error: error)
    }

    public func lastUpdatedInfo() -> Promise<HiveDriveInfo>? {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveHandle.resourceType>())
    }

    public func lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>) -> Promise<HiveDriveInfo>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<resourceType>(error: error)
    }

    public func createDirectory(withPath: String) -> Promise<HiveDirectoryHandle>? {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    public func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> Promise<HiveDirectoryHandle>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveDirectoryHandle>(error: error)
    }

    public func directoryHandle(atPath: String) -> Promise<HiveDirectoryHandle>? {
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    public func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> Promise<HiveDirectoryHandle>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveDirectoryHandle>(error: error)
    }

    public func createFile(withPath: String) -> Promise<HiveFileHandle>? {
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    public func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) -> Promise<HiveFileHandle>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveFileHandle>(error: error)
    }

    public func fileHandle(atPath: String) -> Promise<HiveFileHandle>? {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    public func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) -> Promise<HiveFileHandle>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveFileHandle>(error: error)
    }
}
