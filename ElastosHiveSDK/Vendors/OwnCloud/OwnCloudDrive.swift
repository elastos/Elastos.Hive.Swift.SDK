import Foundation

@objc(OwnCloudDrive)
internal class OwnCloudDrive: HiveDriveHandle {
    override func driveType() -> DriveType {
        return .ownCloud
    }

    override func rootDirectoryHandle() -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    override func createDirectory(atPath: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    override func directoryHandle(atPath: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }
}
