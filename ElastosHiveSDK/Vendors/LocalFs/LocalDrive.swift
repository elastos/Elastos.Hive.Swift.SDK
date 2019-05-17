import Foundation

@objc(LocalDrive)
internal class LocalDrive: HiveDriveHandle {
    override func driveType() -> DriveType {
        return .local
    }

    override func rootDirectoryHandle() -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    override func createDirectory(atPath: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        //TODO
        return nil
    }

    override func directoryHandle(atPath: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }
}
