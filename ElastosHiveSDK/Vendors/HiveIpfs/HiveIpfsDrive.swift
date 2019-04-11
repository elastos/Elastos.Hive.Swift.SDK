import UIKit

@objc(HiveIpfsDrive)
public class HiveIpfsDrive: HiveDrive {
    private static var driveInstance: HiveDrive?

    override public func getDriveType() -> DriveType {
        return DriveType.hiveIpfs
    }
    
    private init(param: HiveIpfsParameters){
        // todo
        super.init()
    }
    
    @objc(createInstance:)
    private static func createInstance(param: HiveIpfsParameters) {
        if driveInstance == nil {
            let drive: HiveIpfsDrive = HiveIpfsDrive(param: param)
            driveInstance = drive as HiveDrive;
        }
    }
    
    @objc(sharedInstance:)
    static func sharedInstance(_ param: HiveIpfsParameters) -> HiveDrive {
        if (driveInstance == nil) {
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
        // todo
    }
    
    public override func createFile(pathname: String) throws -> HiveFile {
        // todo
        return HiveFile()
    }
    
    
}
