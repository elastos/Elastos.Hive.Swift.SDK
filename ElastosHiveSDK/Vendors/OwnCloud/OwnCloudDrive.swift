import Foundation

@objc(OwnCloudDrive)
class OwnCloudDrive: HiveDrive {
    private static var driveInstance: HiveDrive?

    private var authHelper: AuthHelper?
    
    private init(_ param: OwnCloudParameters) {
    }
    
    @objc(createInstance:)
    private static func createInstance(param: OwnCloudParameters) {
        if driveInstance == nil {
            let drive: OwnCloudDrive = OwnCloudDrive(param)
            driveInstance = drive as HiveDrive
        }
    }
    
    static func sharedInstance() -> HiveDrive? {
        return driveInstance
    }

    @objc(getAuthHelper)
    override func getAuthHelper() -> AuthHelper {
        return authHelper!
    }

    override func getDriveType() -> DriveType {
        return .oneDrive
    }

    override func login(_ hiveError: @escaping (HiveDrive.loginResponse)) {

    }

    override func getRootDir(_ result: @escaping (HiveDrive.hiveFileResponse)) {
        
    }

    override func createFile(_ pathname: String, _ responseHandle: @escaping (HiveDrive.hiveFileResponse)) {
        //        try authHelper!.checkExpired()
        //        // TODO
    }

    override func getFile(_ pathname: String, _ responseHandle: @escaping (HiveDrive.hiveFileResponse)) {
        //        try authHelper!.checkExpired()
        //        // TODO
    }
}
