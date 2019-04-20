import Foundation

@objc(HiveIpfsParameters)
public class HiveIpfsParameters: DriveParameters {
    public override func driveType() -> DriveType {
        return DriveType.hiveIpfs
    }
}
