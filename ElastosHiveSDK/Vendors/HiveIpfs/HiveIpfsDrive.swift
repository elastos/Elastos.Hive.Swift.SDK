import UIKit

@objc(HiveIpfsDrive)
public class HiveIpfsDrive: HiveDrive {
    
    private static var hiveIpfsDriveInstance: HiveIpfsDrive?
    override public func getDriveType() -> DriveType {
        return DriveType.hiveIpfs
    }
    
    private init(param: HiveIpfsParameters){
        // todo
        super.init()
    }
    
    @objc(createInstance:)
    public static func createInstance(param: HiveIpfsParameters) {
        let hiveIpfsDrive: HiveIpfsDrive = HiveIpfsDrive.init(param: param)
        hiveIpfsDriveInstance = hiveIpfsDrive
    }
    
    @objc(sharedInstance:)
    public static func sharedInstance(_ param: HiveIpfsParameters) -> HiveIpfsDrive? {
        if(hiveIpfsDriveInstance == nil) {
            createInstance(param: param)
        }
        return hiveIpfsDriveInstance
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
