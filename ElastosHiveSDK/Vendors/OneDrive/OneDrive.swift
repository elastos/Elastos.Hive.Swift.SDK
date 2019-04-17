import Foundation


public class OneDrive: HiveDrive {
    private static var oneDriveInstance: OneDrive?
    private var oneDriveAuthHelper: OneDriveAuthHelper
    private var driveId: String?

    private init(_ param: OneDriveParameters) {
        oneDriveAuthHelper = OneDriveAuthHelper(param.appId!, param.scopes!, param.redirectUrl!)
    }
    
    public static func createInstance(_ param: OneDriveParameters) {
        if oneDriveInstance == nil {
            let drive: OneDrive = OneDrive(param)
            oneDriveInstance = drive as OneDrive
        }
    }
    
    public static func sharedInstance() -> HiveDrive? {
        return oneDriveInstance
    }
    
    override func getDriveType() -> DriveType {
        return .oneDrive
    }

    public override func login(_ hiveError: @escaping (HiveDrive.loginResponse)) {
        oneDriveAuthHelper.login({ (error) in
            // todo handle error
            hiveError(error)
        })
    }

    override func getRootDir() throws -> HiveFile {
        try oneDriveAuthHelper.checkExpired()
        // TODO
        return OneDriveFile()
    }
    
    override func createFile(pathname: String) throws -> HiveFile {
        try oneDriveAuthHelper.checkExpired()
        // TODO
        return OneDriveFile()
    }
    
    override func getFile(pathname: String) throws -> HiveFile {
        try oneDriveAuthHelper.checkExpired()
        // TODO
        return OneDriveFile()
    }
}
