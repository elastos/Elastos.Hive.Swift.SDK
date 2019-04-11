import Foundation

@objc(OwnCloudDrive)
class OwnCloudDrive: HiveDrive {
    private static var driveInstance: HiveDrive?

    private var authHelper: AuthHelper
    
    private init(_ param: OwnCloudParameters) {
        //super.init()
        authHelper = AuthHelper("clientId", "scopes", "redirect_url")
    }
    
    @objc(createInstance:)
    private static func createInstance(param: OwnCloudParameters) {
        if driveInstance == nil {
            let drive: OwnCloudDrive = OwnCloudDrive(param)
            driveInstance = drive as HiveDrive
        }
    }
    
    static func sharedInstance(_ param: OwnCloudParameters) -> HiveDrive {
        if driveInstance == nil {
            createInstance(param: param)
        }
        return driveInstance!
    }

    static func sharedInstance() -> HiveDrive? {
        return driveInstance
    }

    @objc(getAuthHelper)
    override func getAuthHelper() -> AuthHelper {
        return authHelper
    }

    override func getDriveType() -> DriveType {
        return DriveType.oneDrive
    }

    override func login(authenticator: Authenticator) throws {
        authHelper.login(authenticator: authenticator)
    }

    override func getRootDir() throws -> HiveFile {
        try authHelper.checkExpired()
        // TODO
        return OwnCloudFile()
    }

    override func createFile(pathname: String) throws -> HiveFile {
        try authHelper.checkExpired()
        // TODO
        return OwnCloudFile()
    }

    override func getFile(pathname: String) throws -> HiveFile {
        try authHelper.checkExpired()
        // TODO
        return OwnCloudFile()
    }
}
