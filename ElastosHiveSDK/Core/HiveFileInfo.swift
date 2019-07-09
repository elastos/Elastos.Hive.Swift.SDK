import Foundation

public class HiveFileInfo: AttributeMap {
    public static let itemId: String = "ItemId"
    public static let name:   String = "Name"
    public static let size:   String = "Size"

    override init(_ dict: Dictionary<String, String>) {
        super.init(dict)
    }
}
