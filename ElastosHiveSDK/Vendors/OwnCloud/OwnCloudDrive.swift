import UIKit

@objc(OwnCloudDrive)
public class OwnCloudDrive: HiveDrive {
    private static var driveInstance: HiveDrive?

    override public func getDriveType() -> DriveType {
        return DriveType.ownCloud
    }
    
    private init(_ param: OwnCloudParameters) {
        super.init()
    }
    
    @objc(createInstance:)
    private static func createInstance(param: OwnCloudParameters) {
        if driveInstance == nil {
            let drive: OwnCloudDrive = OwnCloudDrive(param)
            driveInstance = drive as HiveDrive
        }
    }
    
    @objc(sharedInstance:)
    static func sharedInstance(_ param: OwnCloudParameters) -> HiveDrive {
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
