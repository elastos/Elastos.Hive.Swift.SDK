import Foundation

@objc(DriveParameter)
public class DriveParameter: NSObject {
    public func driveType() -> DriveType {
        return DriveType.oneDrive
    }

    public static func createForOneDrive(_ clientId: String, _ scope: String, _ redirectUrl: String) -> DriveParameter {
        return OneDriveParameter(clientId, scope, redirectUrl)
    }
}
