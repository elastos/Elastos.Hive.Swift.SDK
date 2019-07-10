import Foundation

///  The `HiveDirectoryInfo` object is a property bag for ClientInfo information.
public class HiveDirectoryInfo: AttributeMap {
    
    /// The unique identifier of the directory within the Drive.
    public static let itemId: String = "ItemId"

    /// The name of the item (filename and extension)
    public static let name: String = "Name"

    /// Collection containing Item objects for the immediate children of Item.
    public static let childCount: String = "ChildCount"

    /// Create a `HiveDirectoryInfo` instance
    ///
    /// - Parameter dict: The dictionary with the `itemId`、`name` and `childCount` key-value
    override init(_ dict: Dictionary<String, String>) {
        super.init(dict)
    }
}
