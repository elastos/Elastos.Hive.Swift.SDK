import Foundation

public typealias HiveResultHandler = ( _ result: Bool?, _ error: HiveError?) -> Void

@objc(HiveClientHandle)
public class HiveClientHandle: NSObject {
    /**
     * Create an instance with specific options.
     *
     * @param options TODO
     * @return An new client instance.
     */
    public static func createInstance(_ param: DriveParameters) {
        let type: DriveType = param.driveType()
        switch type {
        case .local:
            LocalClient.createInstance(param as! LocalParameters)
        case .oneDrive:
            OneDriveClient.createInstance(param as! OneDriveParameters)
        case .ownCloud:
            OwnCloudClient.createInstance(param as! OwnCloudParameters)
        case .dropBox:
            DropboxClient.createInstance(param as! DropBoxParameters)
        case .hiveIpfs:
            HiveIpfsClient.createInstance(param as! HiveIpfsParameters)
        }
    }

    public static func sharedInstance(type: DriveType) -> HiveClientHandle? {
        switch type {
        case .local:
            return LocalClient.sharedInstance()
        case .oneDrive:
            return OneDriveClient.sharedInstance()
        case .ownCloud:
            return OwnCloudClient.sharedInstance()
        case .dropBox:
            return DropboxClient.sharedInstance()
        case .hiveIpfs:
            return HiveIpfsClient.sharedInstance()
        }
    }

    func authHelper() -> AuthHelper {
        return AuthHelper()
    }

    func driveType() -> DriveType {
        return .local
    }

    public func login(withResult: @escaping (HiveResultHandler))  {
    }

    public func logout(withResult: @escaping (HiveResultHandler)) {
    }

    public func GetDefaultDrive() throws -> HiveDriveHandle? {
        return nil
    }
}
