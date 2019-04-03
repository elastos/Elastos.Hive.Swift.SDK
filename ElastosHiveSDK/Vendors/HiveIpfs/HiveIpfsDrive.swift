import UIKit

@objc(HiveIpfsDrive)
public class HiveIpfsDrive: HiveDrive {
    
    @objc public static var sharedInstance: HiveIpfsDrive?
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
        sharedInstance = hiveIpfsDrive
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
