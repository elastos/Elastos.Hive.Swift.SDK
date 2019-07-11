import Foundation

///  The `HiveFileInfo` object is a property bag for ClientInfo information.
public class HiveFileInfo: AttributeMap {
    
    /// The unique identifier of the file within the Drive.
    public static let itemId: String = "ItemId"
    
    /// The name of the item (filename and extension)
    public static let name:   String = "Name"

    /// Size of the item in bytes
    public static let size:   String = "Size"

    /// Create a `HiveFileInfo` instance
    ///
    /// - Parameter dict: The dictionary with the `itemId`, `name` and `size` key-value
    override init(_ dict: Dictionary<String, String>) {
        super.init(dict)
    }
}
