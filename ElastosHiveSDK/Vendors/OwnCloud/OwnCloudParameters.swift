import Foundation

@objc(OwnCloudParameters)
public class OwnCloudParameters: DriveParameters {
    public override func driveType() -> DriveType {
        return DriveType.ownCloud
    }
}
