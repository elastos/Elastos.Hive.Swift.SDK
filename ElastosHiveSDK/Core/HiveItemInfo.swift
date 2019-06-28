import Foundation

public class HiveItemInfo: AttributeMap {
    public static let itemId: String = "itemId"
    public static let name:   String = "name"
    public static let type:   String = "type"
    public static let size:   String = "size"

    override init(_ dict: Dictionary<String, String>) {
        super.init(dict)
    }
}
