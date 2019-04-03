import UIKit

@objc(DropBoxDrive)
public class DropBoxDrive: HiveDrive {
    
    @objc public static var shareInstance: DropBoxDrive?
    override public func getDriveType() -> DriveType {
        return DriveType.dropBox
    }
    
    private init(param: DriveParameters) {
        // TODO;
        super.init()
    }
    
    @objc public static func createInstance(param: DriveParameters){
        let dropBoxDrive: DropBoxDrive = DropBoxDrive.init(param: param)
        shareInstance = dropBoxDrive
    }
    
    public override func logIn(authenticator: Authenticator) throws -> Bool {
        // todo
        return false
    }
    
    override public func getRootDir() throws -> HiveFile {
        // todo
        return HiveFile()
    }
    
    override public func getFile(pathname: String) throws {
        // todo
    }
    
    override public func createFile(pathname: String) throws -> HiveFile {
        // todo
        return HiveFile()
    }
    
}
