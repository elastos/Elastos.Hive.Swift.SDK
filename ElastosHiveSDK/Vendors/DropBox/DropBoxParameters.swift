import Foundation

@objc(DropBoxParameters)
public class DropBoxParameters: DriveParameters {
    public override func driveType() -> DriveType {
        return .dropBox
    }
}
