import Foundation

@objc(OwnCloudDrive)
internal class OwnCloudDrive: HiveDriveHandle {
    private static var driveInstance: HiveDriveHandle?

    private var authHelperHandle: AuthHelper?
    
    private init(_ param: OwnCloudParameters) {
    }
    
    @objc(createInstance:)
    private static func createInstance(param: OwnCloudParameters) {
        if driveInstance == nil {
            let drive: OwnCloudDrive = OwnCloudDrive(param)
            driveInstance = drive as HiveDriveHandle
        }
    }
    
    static func sharedInstance() -> HiveDriveHandle? {
        return driveInstance
    }

    override func authHelper() -> AuthHelper {
        return AuthHelper()
    }

    override func driveType() -> DriveType {
        return .ownCloud
    }

    override func login(_ athenticator: Authenticator) throws {
        // TODO
    }

    override func rootDirectoryHandle(withResult: @escaping HiveFileObjectCreationResponseHandler) throws {
        // TODO
    }

    override func createDirectory(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) throws {
        // TODO
    }

    override func createFile(atPath: String, contents: Data?, withResult: @escaping HiveFileObjectCreationResponseHandler) throws {
        // TODO
    }

    override func getFileHandle(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) throws {
        // TODO
    }
}
