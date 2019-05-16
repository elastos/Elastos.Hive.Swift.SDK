import Foundation

@objc(HiveIpfsDrive)
internal class HiveIpfsDrive: HiveDriveHandle {
    override func driveType() -> DriveType {
        return .ownCloud
    }

    override func rootDirectoryHandle() -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    override func createDirectory(atPath: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        // TODO
        return nil
    }

    override func createFile(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        return nil
    }

    override func directoryHandle(atPath: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }
}
