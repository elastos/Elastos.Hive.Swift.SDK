import Foundation

@objc(DriveParameters)
public class DriveParameters: NSObject {
    public override init() {
        super.init()
    }
    
    @objc(createForOneDrive:scopes:redirectUrl:)
    public static func createForOneDrive(applicationId: String, scopes: String, redirectUrl: String) -> DriveParameters {
        return OneDriveParameters(applicationId, scopes, redirectUrl)
    }

    @objc
    public var driveType: DriveType {
        return DriveType.oneDrive
    }
}
