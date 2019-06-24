import Foundation

public class HiveDriveInfo: AttributeMap {
    public static let driveId: String = "DriveId"
    override init(_ hash: Dictionary<String, String>) {
        super.init(hash)
    }
}
