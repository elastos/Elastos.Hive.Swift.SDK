import UIKit

@objc(HiveDrive)
public class HiveDrive: NSObject {
    
    @objc public var authHelper: AuthHelper?
    
    /**
     * Create an instance with specific options.
     *
     * @param options TODO
     * @return An new drive instance.
     */
    @objc(sharedInstance:error:)
    public static func sharedInstance(param: DriveParameters) throws -> HiveDrive {
        
        switch param.driveType {
        case .oneDrive:
            return OneDrive.sharedInstance(param as! OneDriveParameters)
        case .ownCloud:
            return OwnCloudDrive.sharedInstance(param as! OwnCloudParameters)
        case .dropBox:
            return DropboxDrive.sharedInstance(param as! DropBoxParameters)
        case .hiveIpfs:
            return HiveIpfsDrive.sharedInstance(param as! HiveIpfsParameters)
        }
    }

    public static func sharedInstance(type: DriveType) -> HiveDrive? {
        switch type {
        case .oneDrive:
            return OneDrive.sharedInstance()
        case .ownCloud:
            return OwnCloudDrive.sharedInstance()
        case .dropBox:
            return DropboxDrive.sharedInstance()
        case .hiveIpfs:
            return HiveIpfsDrive.sharedInstance()
        }
    }
    
    @objc(createFile:error:)
    public func createFile(pathname: String) throws -> HiveFile {
        return HiveFile()
    }
    
    /**
     * Login onto OneDrive to get authorization and authentication.
     *
     * @return TODO
     * @throws Exception TODO
     */
    public func logIn(authenticator: Authenticator) throws -> Bool {
        return false
    }
    
    /**
     * Get drive type.
     *
     * @return The drive type.
     */
    @objc(getDriveType)
    public func getDriveType() -> DriveType {
        return DriveType.oneDrive // default value
    }
    
    /**
     * Get the root Hive file object.
     *
     * @return The hive file.
     * @throws Exception The exception
     */
    @objc(getRootDir:)
    public func getRootDir() throws -> HiveFile {
        
        return HiveFile()
    }
    
    /**
     * Get the specific hive file object.
     *
     * @param pathName The target pathname to acquire.
     * @return The hive file.
     * @throws Exception The exception.
     */
    @objc(getFile:error:)
    public func getFile(pathname: String) throws {
        
    }
    
    /**
     *
     * @return True or false.
     */
    public func someMethod() -> Bool {
        return true
    }
}
