import Foundation

@objc(DriveParameter)
public class DriveParameter: NSObject {
    public func driveType() -> DriveType {
        return DriveType.oneDrive
    }

    public static func createForOneDrive(_ clientId: String, _ scope: String, _ redirectUrl: String) -> DriveParameter {
        return OneDriveParameter(clientId, scope, redirectUrl)
    }

    public static func createForIpfsDrive(_ uid: String, _ path: String) -> DriveParameter {
        return HiveIpfsParameter(uid, path)
    }
}
