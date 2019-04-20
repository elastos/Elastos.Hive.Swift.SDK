import Foundation

@objc(HiveIpfsDrive)
class HiveIpfsDrive: HiveDriveHandle {
    private static var driveInstance: HiveDriveHandle?

    private var authHelperHandle: AuthHelper?
    
    private init(param: HiveIpfsParameters){
        // todo
        // super.init()
    }
    
    @objc(createInstance:)
    private static func createInstance(param: HiveIpfsParameters) {
        if driveInstance == nil {
            let drive: HiveIpfsDrive = HiveIpfsDrive(param: param)
            driveInstance = drive as HiveDriveHandle;
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

    override func login() throws {
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
