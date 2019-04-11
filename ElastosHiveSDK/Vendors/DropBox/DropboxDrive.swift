import UIKit

@objc(DropBoxDrive)
public class DropboxDrive: HiveDrive {
    private static var driveInstance: HiveDrive?

    override public func getDriveType() -> DriveType {
        return DriveType.dropBox
    }
    
    private init(_ param: DriveParameters) {
        // TODO;
        super.init()
    }
    
    @objc(createInstance:)
    public static func createInstance(param: DriveParameters){
        if driveInstance == nil {
            let drive: DropboxDrive = DropboxDrive(param)
            driveInstance = drive as HiveDrive
        }
    }
    
    @objc(sharedInstance:)
    static func sharedInstance(_ param: DropBoxParameters) -> HiveDrive {
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
