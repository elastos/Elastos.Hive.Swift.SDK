import Foundation

@objc(OwnCloudDrive)
class OwnCloudDrive: HiveDriveHandle {
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

    override func login(_ hiveError: @escaping (LoginHandle)) {
        // TODO
    }

    override func rootDirectoryHandle(withResult: @escaping HiveFileObjectCreationResponseHandler) {
        // TODO
    }

    override func createDirectory(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) {
        // TODO
    }

    override func createFile(atPath: String, contents: Data?, withResult: @escaping HiveFileObjectCreationResponseHandler) {
        // TODO
    }

    override func getFileHandle(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) {
        // TODO
    }
}
