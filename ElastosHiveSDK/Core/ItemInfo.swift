

import UIKit

public class ItemInfo: HiveAttributeMap {

    public static let itemId: String = "itemId"
    public static let name: String = "name"
    public static let type: String = "type"
    public static let size: String = "size"

    override init(_ hash: Dictionary<String, String>) {
        super.init(hash)
    }
}
