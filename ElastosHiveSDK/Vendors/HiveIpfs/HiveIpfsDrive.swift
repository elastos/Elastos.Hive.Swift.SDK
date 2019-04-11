import Foundation

@objc(HiveIpfsDrive)
class HiveIpfsDrive: HiveDrive {
    private static var driveInstance: HiveDrive?

    private var authHelper: AuthHelper;

    private init(param: HiveIpfsParameters){
        // todo
        // super.init()
        authHelper = AuthHelper("clientId", "scopes", "redirect_url")
    }
    
    @objc(createInstance:)
    private static func createInstance(param: HiveIpfsParameters) {
        if driveInstance == nil {
            let drive: HiveIpfsDrive = HiveIpfsDrive(param: param)
            driveInstance = drive as HiveDrive;
        }
    }

    static func sharedInstance(_ param: HiveIpfsParameters) -> HiveDrive {
        if (driveInstance == nil) {
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
        return DriveType.hiveIpfs
    }

    override func login(authenticator: Authenticator) throws {
        authHelper.login(authenticator: authenticator)
    }

    override func getRootDir() throws -> HiveFile {
        try authHelper.checkExpired()
        // TODO
        return HiveIpfsFile()
    }

    override func createFile(pathname: String) throws -> HiveFile {
        try authHelper.checkExpired()
        // TODO
        return HiveIpfsFile()
    }

    override func getFile(pathname: String) throws -> HiveFile {
        try authHelper.checkExpired()
        // TODO
        return HiveIpfsFile()
    }
}
