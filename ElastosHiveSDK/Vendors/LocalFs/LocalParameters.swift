import Foundation

@objc(LocalParameters)
public class LocalParameters: DriveParameters {
    public override func driveType() -> DriveType {
        return DriveType.local
    }
}
