import Foundation
import PromiseKit

@objc(HiveDrive)
public class HiveDriveHandle: NSObject, HiveResourceItem, HiveDirectoryItem {
    public typealias resourceType = HiveDriveInfo
    public var driveType: DriveType
    public var handleId: String?
    public var lastInfo: HiveDriveInfo

    internal init(_ driveType: DriveType, _ info: HiveDriveInfo) {
        self.driveType = driveType
        self.lastInfo = info
        self.handleId = lastInfo.driveId
    }

    public func rootDirectoryHandle() -> HivePromise<HiveDirectoryHandle> {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    public func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveHandle.resourceType>())
    }

    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<resourceType>(error: error)
    }

    public func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    public func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    public func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    public func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    public func createFile(withPath: String) -> HivePromise<HiveFileHandle> {
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    public func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }

    public func fileHandle(atPath: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    public func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }
}
