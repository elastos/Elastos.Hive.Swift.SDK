import UIKit

@objc(OneDrive)
public class OneDrive: HiveDrive {
    
    @objc public static var sharedInstance: OneDrive?
    override public func getDriveType() -> DriveType {
        return DriveType.oneDrive
    }
    
    private init(param: OneDriveParameters) {
        super.init()
        authHelper = OneDriveAuthHelper(appId: param.appId, scopes: param.scopes, redirectUrl: param.redirectUrl)
    }
    
    @objc(createInstanceWithParam:)
    public static func createInstance(param: OneDriveParameters) {
        let oneDrive: OneDrive = OneDrive.init(param: param)
        sharedInstance = oneDrive
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
