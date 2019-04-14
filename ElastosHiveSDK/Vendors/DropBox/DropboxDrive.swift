import Foundation

@objc(DropboxDrive)
class DropboxDrive: HiveDrive {
    private static var driveInstance: HiveDrive?

    private var authHelper: AuthHelper?

    private init(_ param: DriveParameters) {
        // TODO;
        //super.init()
        
    }
    
    @objc(createInstance:)
    public static func createInstance(param: DriveParameters){
        if driveInstance == nil {
            let drive: DropboxDrive = DropboxDrive(param)
            driveInstance = drive as HiveDrive
        }
    }
    
    static func sharedInstance(_ param: DropBoxParameters) -> HiveDrive {
        if driveInstance == nil {
            createInstance(param: param)
        }
        return driveInstance!
    }

    static func sharedInstance() -> HiveDrive? {
        return driveInstance
    }
    
    override func getAuthHelper() -> AuthHelper {
        return authHelper!
    }

    override func getDriveType() -> DriveType {
        return DriveType.oneDrive
    }

    override func login(authenticator: Authenticator) throws {
        
    }

    override func getRootDir() throws -> HiveFile {
        try authHelper!.checkExpired()
        // TODO
        return DropboxFile()
    }

    override func createFile(pathname: String) throws -> HiveFile {
        try authHelper!.checkExpired()
        // TODO
        return DropboxFile()
    }

    override func getFile(pathname: String) throws -> HiveFile {
        try authHelper!.checkExpired()
        // TODO
        return DropboxFile()
    }
}
