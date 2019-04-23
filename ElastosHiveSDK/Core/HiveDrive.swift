import Foundation

public typealias LoginHandle = (_ error: HiveError?) -> Void
public typealias HiveFileObjectCreationResponseHandler = (_ files: HiveFileHandle?, _ error: HiveError?) -> Void

@objc(HiveDrive)
public class HiveDriveHandle: NSObject {
    /**
     * Create an instance with specific options.
     *
     * @param options TODO
     * @return An new drive instance.
     */
    public static func createInstance(_ param: DriveParameters) {
        let type: DriveType = param.driveType()
        switch type {
        case .oneDrive:
            OneDrive.createInstance(param as! OneDriveParameters)
        case .ownCloud:
            OwnCloudDrive.createInstance(param as! OwnCloudParameters)
        case .dropBox:
            DropboxDrive.createInstance(param as! DropBoxParameters)
        case .hiveIpfs:
            HiveIpfsDrive.createInstance(param as! HiveIpfsParameters)
        }
    }

    public static func sharedInstance(type: DriveType) -> HiveDriveHandle? {
        switch type {
        case .oneDrive:
            return OneDrive.sharedInstance()
        case .ownCloud:
            return OwnCloudDrive.sharedInstance()
        case .dropBox:
            return DropboxDrive.sharedInstance()
        case .hiveIpfs:
            return HiveIpfsDrive.sharedInstance()
        }
    }

    func authHelper() -> AuthHelper {
        return AuthHelper()
    }

    func driveType() -> DriveType {
        return .oneDrive
    }

    public func login(_ hiveError: @escaping (LoginHandle))  {
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
