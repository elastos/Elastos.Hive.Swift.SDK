import Foundation

@objc(OneDrive)
class OneDrive: HiveDrive {
    private static var driveInstance: HiveDrive?

    private var authHelper: AuthHelper
    
    private init(_ param: OneDriveParameters) {
        authHelper = OneDriveAuthHelper(param.appId, param.scopes, param.redirectUrl)
    }

    @objc(createInstanceWithParam:)
    private static func createInstance(param: OneDriveParameters) {
        if driveInstance == nil {
            let drive: OneDrive = OneDrive(param)
            driveInstance = drive as HiveDrive
        }
    }

    static func sharedInstance(_ param: OneDriveParameters) -> HiveDrive {
        if driveInstance == nil {
            createInstance(param: param)
        }
        return driveInstance!
    }

    static func sharedInstance() -> HiveDrive? {
        return driveInstance
    }

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
        return OneDriveFile()
    }

    override func createFile(pathname: String) throws -> HiveFile {
        try authHelper.checkExpired()
        // TODO
        return OneDriveFile()
    }

    override func getFile(pathname: String) throws -> HiveFile {
        try authHelper.checkExpired()
        // TODO
        return OneDriveFile()
    }
}
