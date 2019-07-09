import Foundation

public class HiveDirectoryInfo: AttributeMap {
    public static let itemId: String = "ItemId"
    public static let name: String = "Name"
    public static let childCount: String = "ChildCount"

    override init(_ dict: Dictionary<String, String>) {
        super.init(dict)
    }
}
