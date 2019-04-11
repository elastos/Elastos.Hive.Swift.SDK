import Foundation

@objc(HiveDrive)
public class HiveDrive: NSObject {
    /**
     * Create an instance with specific options.
     *
     * @param options TODO
     * @return An new drive instance.
     */
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
}

extension HiveDrive {
    @objc(getAuthHelper)
    func getAuthHelper() -> AuthHelper {
        return AuthHelper()
    }

    @objc(getDriveType)
    func getDriveType() -> DriveType {
        return DriveType.oneDrive
    }

    @objc(login::)
    func login(authenticator: Authenticator) throws  {
    }

    @objc(getRootDir:)
    func getRootDir() throws -> HiveFile {
        return HiveFile()
    }

    @objc(createFile::)
    func createFile(pathname: String) throws -> HiveFile {
        return HiveFile()
    }

    @objc(getFile::)
    func getFile(pathname: String) throws -> HiveFile {
        return HiveFile()
    }
}
