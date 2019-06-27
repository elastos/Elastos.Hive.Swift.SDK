import Foundation
import PromiseKit

public typealias HivePromise = Promise

@objc(HiveClient)
public class HiveClientHandle: Result, ResourceItem{
    
    public typealias resourceType = HiveClientInfo
    public let driveType: DriveType
    public var handleId: String?
    public var lastInfo: HiveClientInfo?
    internal var authHelper: AuthHelper?
    internal var token: AuthToken?

    /// Creates an instance with the specified `driveType`.
    ///
    /// - Parameter driveType: The `DriveType` instance
    internal init(_ driveType: DriveType) {
        self.driveType = driveType
    }

    /// Creates an instance with the specific `OneDriveParameter`,
    /// `DropBoxParameter`, `OwnCloudParameter`, 'IPFSParameter' and 'NativeParameter'.
    ///
    /// - Parameter param: Client singleton type & requred param,
    ///   for example: use a OneDriveParameter will create OneDriveClient singleton
    public static func createInstance(_ param: DriveParameter) {
        let type: DriveType = param.driveType()
        switch type {
        case .nativeStorage:
            NativeClient.createInstance(param as! NativeParameter)
        case .oneDrive:
            OneDriveClient.createInstance(param as! OneDriveParameter)
        case .ownCloud:
            OwnCloudClient.createInstance(param as! OwnCloudParameter)
        case .dropBox:
            DropboxClient.createInstance(param as! DropBoxParameter)
        case .hiveIPFS:
            IPFSClient.createInstance(param as! IPFSParameter)
        }
    }

    /// Returns a spacific HiveClient singleton
    ///
    /// - Parameter type: will returns type
    /// - Returns: return a HiveClient singleton
    public static func sharedInstance(type: DriveType) -> HiveClientHandle? {
        switch type {
        case .nativeStorage:
            return NativeClient.sharedInstance()
        case .oneDrive:
            return OneDriveClient.sharedInstance()
        case .ownCloud:
            return OwnCloudClient.sharedInstance()
        case .dropBox:
            return DropboxClient.sharedInstance()
        case .hiveIPFS:
            return IPFSClient.sharedInstance()
        }
    }

    /// Login with account
    ///
    /// - Parameter Authenticator: authenticator instance,
    ///   implement related delegate for authorization
    /// - Returns:  Returns `true` if the login succees, `false` otherwise.
    public func login(_ authenticator: Authenticator) throws {}

    /// Logout with account
    ///
    /// - Returns: Returns `true` if the logout succees, `false` otherwise.
    public func logout() throws {}

    /// Last update for HiveClientHandle subclasses
    ///
    /// - Returns: Returns the latest update information for the subclasses
    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<resourceType>())
    }

    /// Last update for HiveClientHandle subclasses
    ///
    /// - Parameter handleBy: the result of returns
    /// - Returns: Returns the latest update information for the subclasses
    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<resourceType>(error: error)
    }

    /// Creates a default HiveDriveHandle for subclasses
    ///
    /// - Returns: Returns singleton instance for subclasses
    public func defaultDriveHandle() -> HivePromise<HiveDriveHandle> {
        return defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>())
    }

    /// Creates a default HiveDriveHandle for subclasses
    ///
    /// - Parameter handleBy: the result of returns
    /// - Returns: Returns singleton instance for subclasses
    public func defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>) -> HivePromise<HiveDriveHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDriveHandle>(error: error)
    }
}
