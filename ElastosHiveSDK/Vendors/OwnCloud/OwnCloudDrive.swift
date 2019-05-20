import Foundation
import PromiseKit

@objc(OwnCloudDrive)
internal class OwnCloudDrive: HiveDriveHandle {
    override func driveType() -> DriveType {
        return .ownCloud
    }

    override func rootDirectoryHandle() -> Promise<HiveDirectoryHandle>? {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>)
        -> Promise<HiveDirectoryHandle>? {
        // TODO
        return nil
    }

    @objc
    override var lastInfo: HiveDriveInfo  {
        get {
            return self.lastInfo
        }
        set (newInfo) {
            self.lastInfo = newInfo
        }
    }

    @objc
    override var uniqueId: String {
        get {
            return self.uniqueId;
        }
    }

    override func lastUpdatedInfo() -> Promise<HiveDriveInfo>? {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>) -> Promise<HiveDriveInfo>? {
        // TODO
        return nil
    }

    override func createDirectory(withPath: String) -> Promise<HiveDirectoryHandle>? {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> Promise<HiveDirectoryHandle>? {
        // TODO
        return nil
    }

    override func directoryHandle(atPath: String) -> Promise<HiveDirectoryHandle>? {
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> Promise<HiveDirectoryHandle>? {
        // TODO
        return nil
    }

    override func createFile(withPath: String) -> Promise<HiveFileHandle>? {
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> Promise<HiveFileHandle>? {
        // TODO
        return nil
    }

    override func fileHandle(atPath: String) -> Promise<HiveFileHandle>? {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> Promise<HiveFileHandle>? {
        // TODO
        return nil
    }
}
