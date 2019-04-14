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
        return DriveType.oneDrive
    }
    
    public func login() throws {
        try oneDriveAuthHelper.login()
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
