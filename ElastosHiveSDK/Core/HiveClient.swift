import Foundation
import PromiseKit

@objc(HiveClient)
public class HiveClientHandle: NSObject, HiveResourceItem{
    public let driveType: DriveType
    internal var authHelper: AuthHelper?
    internal var token: AuthToken?
    internal var _clientId: String?
    internal var _lastInfo: HiveClientInfo?

    internal init(_ driveType: DriveType) {
        self.driveType = driveType
    }

    /**
     * Create an instance with specific options.
     *
     * @param options TODO
     * @return An new client instance.
     */
    public static func createInstance(_ param: DriveParameter) {
        let type: DriveType = param.driveType()
        switch type {
        case .local:
            LocalClient.createInstance(param as! LocalParameter)
        case .oneDrive:
            OneDriveClient.createInstance(param as! OneDriveParameter)
        case .ownCloud:
            OwnCloudClient.createInstance(param as! OwnCloudParameter)
        case .dropBox:
            DropboxClient.createInstance(param as! DropBoxParameter)
        case .hiveIpfs:
            HiveIpfsClient.createInstance(param as! HiveIpfsParameter)
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

    @objc
    public var handleId: String? {
        get {
            return self._clientId;
        }
    }

    public typealias resourceType = HiveClientInfo
    @objc
    public var lastInfo: resourceType?  {
        get {
            return self._lastInfo
        }
        set (newInfo) {
            self._lastInfo = newInfo
        }
    }

    public func login(_ authenticator: Authenticator) -> Bool? {
        return nil
    }

    public func logout() -> Bool? {
        return nil
    }

    public func lastUpdatedInfo() -> Promise<resourceType>? {
        return lastUpdatedInfo(handleBy: HiveCallback<resourceType>())
    }

    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> Promise<resourceType>? {
        let error = HiveError.failue(des: "TODO")
        return Promise<resourceType>(error: error)
    }

    public func defaultDriveHandle() -> Promise<HiveDriveHandle>? {
        return defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>())
    }

    public func defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>) -> Promise<HiveDriveHandle>? {
        let error = HiveError.failue(des: "TODO")
        return Promise<HiveDriveHandle>(error: error)
    }
}
