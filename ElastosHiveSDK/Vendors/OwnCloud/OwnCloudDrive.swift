import UIKit

@objc(OwnCloudDrive)
public class OwnCloudDrive: HiveDrive {
    
    @objc public static var sharedInstance: OwnCloudDrive?
    override public func getDriveType() -> DriveType {
        return DriveType.ownCloud
    }
    
    private init(param: OwnCloudParameters) {
        super.init()
    }
    
    @objc(createInstance:)
    public static func createInstance(param: OwnCloudParameters) {
        let ownCloudDrive: OwnCloudDrive = OwnCloudDrive.init(param: param)
        sharedInstance = ownCloudDrive
    }
    
    public override func logIn(authenticator: Authenticator) throws -> Bool {
        // todo
        return false
    }
    
    public override func getRootDir() throws -> HiveFile {
        // todo
        return HiveFile()
    }
    
    public override func getFile(pathname: String) throws {
        //
    }
    
    public override func createFile(pathname: String) throws -> HiveFile {
        return HiveFile()
    }
    
    
}
