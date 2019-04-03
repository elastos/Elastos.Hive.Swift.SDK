import UIKit

@objc(OneDrive)
public class OneDrive: HiveDrive {
    
    private static var oneDriveInsatance: OneDrive?
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
        oneDriveInsatance = oneDrive
    }
    
    @objc(sharedInstance:)
    public static func sharedInstance(param: OneDriveParameters) -> OneDrive? {
        if(oneDriveInsatance == nil){
            createInstance(param: param)
        }
        return oneDriveInsatance
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
