import Foundation

public typealias HiveFileObjectCreationResponseHandler = (_ file: HiveFileHandle?, _ error: HiveError?) -> Void

@objc(HiveDrive)
public class HiveDriveHandle: NSObject {
    func driveType() -> DriveType {
        return .local
    }

    public func rootDirectoryHandle(withResult: @escaping HiveFileObjectCreationResponseHandler) throws {
    }

    public func createDirectory(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) throws {
    }

    public func createFile(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) throws {
    }

    public func getFileHandle(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) throws {
    }
}
