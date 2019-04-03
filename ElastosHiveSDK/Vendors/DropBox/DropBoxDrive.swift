import UIKit

@objc(DropBoxDrive)
public class DropBoxDrive: HiveDrive {
    
    private static var dropBoxDriveInstance: DropBoxDrive?
    override public func getDriveType() -> DriveType {
        return DriveType.dropBox
    }
    
    private init(param: DriveParameters) {
        // TODO;
        super.init()
    }
    
    @objc(createInstance:)
    public static func createInstance(param: DriveParameters){
        let dropBoxDrive: DropBoxDrive = DropBoxDrive.init(param: param)
        dropBoxDriveInstance = dropBoxDrive
    }
    
    @objc(sharedInsatace:)
    public static func sharedInsatace(param: DropBoxParameters) -> DropBoxDrive? {
        if(dropBoxDriveInstance == nil) {
            createInstance(param: param)
        }
        return dropBoxDriveInstance
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
