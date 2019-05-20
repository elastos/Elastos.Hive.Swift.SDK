import Foundation
import PromiseKit

@objc(HiveDrive)
public class HiveDriveHandle: NSObject, HiveResourceItem, HiveDirectoryItem {
    public let driveType: DriveType

    internal init(_ driveType: DriveType) {
        self.driveType = driveType
    }

    @objc
    var handleId: String? {
        get {
            return nil
        }
    }

    internal typealias resourceType = HiveDriveInfo
    @objc
    var lastInfo: resourceType? {
        get {
            return nil
        }
        set (newInfo) {
        }
    }

    public func rootDirectoryHandle() -> Promise<HiveDirectoryHandle>? {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    public func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>) -> Promise<HiveDirectoryHandle>? {
        let error = HiveError.failue(des: "HiveDriveHandle::rootDirectoryHandle")
        return Promise<HiveDirectoryHandle>(error: error)
    }

    func lastUpdatedInfo() -> Promise<resourceType>? {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveHandle.resourceType>())
    }

    func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> Promise<resourceType>? {
        let error = HiveError.failue(des: "HiveDriveHandle::lastUpdatedInfo")
        return Promise<resourceType>(error: error)
    }

    public func createDirectory(withPath: String) -> Promise<HiveDirectoryHandle>? {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    public func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> Promise<HiveDirectoryHandle>? {
        let error = HiveError.failue(des: "HiveDriveHandle::createDirectory")
        return Promise<HiveDirectoryHandle>(error: error)
    }

    public func directoryHandle(atPath: String) -> Promise<HiveDirectoryHandle>? {
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    public func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> Promise<HiveDirectoryHandle>? {
        let error = HiveError.failue(des: "HiveDriveHandle::directoryHandle")
        return Promise<HiveDirectoryHandle>(error: error)
    }

    public func createFile(withPath: String) -> Promise<HiveFileHandle>? {
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    public func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) -> Promise<HiveFileHandle>? {
        let error = HiveError.failue(des: "HiveDriveHandle::createFile")
        return Promise<HiveFileHandle>(error: error)
    }

    public func fileHandle(atPath: String) -> Promise<HiveFileHandle>? {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    public func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) -> Promise<HiveFileHandle>? {
        let error = HiveError.failue(des: "HiveDriveHandle::createFile")
        return Promise<HiveFileHandle>(error: error)
    }
}
