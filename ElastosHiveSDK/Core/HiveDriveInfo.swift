import Foundation

///  The `HiveDriveInfo` object is a property bag for ClientInfo information.
public class HiveDriveInfo: AttributeMap {

    /// The unique identifier of the drive.
    public static let driveId: String = "DriveId"


    /// Create a `HiveDriveInfo` instance
    ///
    /// - Parameter dict: The dictionary with the `driveId` key-value
    override init(_ dict: Dictionary<String, String>) {
        super.init(dict)
    }
}
