import Foundation

@objc(DropboxDrive)
internal class DropboxDrive: HiveDriveHandle {
    private static var driveInstance: HiveDriveHandle?

    private var authHelperHandle: AuthHelper?

    private init(_ param: DriveParameters) {
        // TODO;
        //super.init()
    }

    @objc(createInstance:)
    public static func createInstance(param: DriveParameters){
        if driveInstance == nil {
            let drive: DropboxDrive = DropboxDrive(param)
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

    override func createFile(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) {

    }

    override func getFileHandle(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) {
        // TODO
    }
}
