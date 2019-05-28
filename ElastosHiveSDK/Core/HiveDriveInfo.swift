import Foundation

public enum DriveState {
    case normal
    case nearing
    case critical
    case exceeded
}

public class HiveDriveInfo: NSObject {
    public var capacity: String?
    public var used: String?
    public var remaining: String?
    public var deleted: String?
    public var fileCount: String?
    public var state: String?
    public var lastModifiedDateTime: String?
    public var ddescription: String?
    public var driveState: DriveState?

}
