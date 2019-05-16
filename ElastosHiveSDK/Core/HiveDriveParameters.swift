import Foundation

@objc(DriveParameters)
public class DriveParameters: NSObject {
    public func driveType() -> DriveType {
        return DriveType.oneDrive
    }

    public static func createForOneDrive(applicationId: String, scopes: Array<String>?, redirectUrl: String) -> DriveParameters {
        return OneDriveParameters(applicationId, scopes, redirectUrl)
    }
}
