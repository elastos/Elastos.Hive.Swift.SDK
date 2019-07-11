import Foundation

@objc(DriveParameter)

/// Configuration Paramsters for the ElastosHiveSDK.
public class DriveParameter: NSObject {

    /// Returns a type, default `oneDrive`
    ///
    /// - Returns: Returns a type, default `oneDrive`
    public func driveType() -> DriveType {
        return DriveType.oneDrive
    }

    /// Creates an instance of the specific `OneDriveParameter` type.
    ///
    /// - Parameters:
    ///   - clientId: ClientId for OneDrive registered with Microsoft Account.
    ///   - scope: Scopes to be used for OneDrive registered with Microsoft Account.
    ///   - redirectUrl: Redirect URL for OneDrive.
    /// - Returns: Returns parameter instance
    public static func createForOneDrive(_ clientId: String, _ scope: String, _ redirectUrl: String) -> DriveParameter {
        return OneDriveParameter(clientId, scope, redirectUrl)
    }

    /// Creates an instance of the specific `IPFSParameter` type.
    ///
    /// - Parameter uid: a unique UID. The UID can be used to identify endpoints in communication.
    /// - Returns: Returns parameter instance.
    public static func createForIpfsDrive(_ uid: String) -> DriveParameter {
        return IPFSParameter(uid)
    }
}
