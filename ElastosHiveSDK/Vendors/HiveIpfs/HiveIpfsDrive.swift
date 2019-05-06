import Foundation

@objc(HiveIpfsDrive)
internal class HiveIpfsDrive: HiveDriveHandle {
    override func driveType() -> DriveType {
        return .ownCloud
    }

    override func rootDirectoryHandle(withResult: @escaping HiveFileObjectCreationResponseHandler) {
        // TODO
    }

    override func createDirectory(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) {
        // TODO
    }
    
    override func createFile(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) {
        // TODO
    }

    override func getFileHandle(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) {
        // TODO
    }
}
