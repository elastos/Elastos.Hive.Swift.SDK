import Foundation

///  The `HiveItemInfo` object is a property bag for ClientInfo information.
public class HiveItemInfo: AttributeMap {

    /// The unique identifier of the item within the Drive.
    public static let itemId: String = "itemId"

    /// The name of the item (filename and extension)
    public static let name:   String = "name"

    /// The item type is `file` or `directory`
    public static let type:   String = "type"

    /// Size of the item in bytes
    public static let size:   String = "size"

    /// Create a `HiveItemInfo` instance
    ///
    /// - Parameter dict: The dictionary with the `itemId`、`name`、`type` and `size` key-value
    override init(_ dict: Dictionary<String, String>) {
        super.init(dict)
    }
}
