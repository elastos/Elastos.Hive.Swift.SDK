import Foundation
import PromiseKit

public typealias HivePromise = Promise

@objc(HiveClient)
public class HiveClientHandle: NSObject, HiveResourceItem{
    public typealias resourceType = HiveClientInfo
    public let driveType: DriveType
    public var handleId: String?
    public var lastInfo: HiveClientInfo?
    internal var authHelper: AuthHelper?
    internal var token: AuthToken?

    internal init(_ driveType: DriveType) {
        self.driveType = driveType
        self.handleId = lastInfo?.userId
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

    public func login(_ authenticator: Authenticator) -> Bool {
        return false
    }

    public func logout() -> Bool {
        return false
    }

    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<resourceType>())
    }

    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType> {
        let error = HiveError.failue(des: "TODO")
        return HivePromise<resourceType>(error: error)
    }

    public func defaultDriveHandle() -> HivePromise<HiveDriveHandle> {
        return defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>())
    }

    public func defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>) -> HivePromise<HiveDriveHandle> {
        let error = HiveError.failue(des: "TODO")
        return HivePromise<HiveDriveHandle>(error: error)
    }
}
