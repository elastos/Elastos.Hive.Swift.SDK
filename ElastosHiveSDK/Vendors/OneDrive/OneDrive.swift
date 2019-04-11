import UIKit

@objc(OneDrive)
public class OneDrive: HiveDrive {
    private static var driveInstance: HiveDrive?

    override public func getDriveType() -> DriveType {
        return DriveType.oneDrive
    }
    
    private init(_ param: OneDriveParameters) {
        super.init()
        authHelper = OneDriveAuthHelper(appId: param.appId, scopes: param.scopes, redirectUrl: param.redirectUrl)
    }
    
    @objc(createInstanceWithParam:)
    private static func createInstance(param: OneDriveParameters) {
        if driveInstance == nil {
            let drive: OneDrive = OneDrive(param)
            driveInstance = drive as HiveDrive
        }
    }
    
    @objc(sharedInstance:)
    static func sharedInstance(_ param: OneDriveParameters) -> HiveDrive {
        if driveInstance == nil {
            createInstance(param: param)
        }
        return driveInstance!
    }

    @objc(sharedInstance)
    static func sharedInstance() -> HiveDrive? {
        return driveInstance
    }
    
    public override func logIn(authenticator: Authenticator) throws -> Bool {
        return (authHelper?.login(authenticator: authenticator))!
    }
    
    public override func getRootDir() throws -> HiveFile {
        try authHelper?.checkExpired()
        // todo
        return OnedriveFile()
    }
    
    public override func createFile(pathname: String) throws -> HiveFile {
        try authHelper?.checkExpired()
        // todo
        return OnedriveFile()
    }
    
}
