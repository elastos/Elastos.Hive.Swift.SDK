

import UIKit

public class HiveChildren: NSObject {

    public var children: Array<HiveItem>

    public override init() {
        children = []
    }

    func installValue(_ jsonData: JSON) {
        let childrenData = jsonData["value"].arrayValue
        for item in childrenData {
            let hiveItem = HiveItem()
            hiveItem.installValue(item)
            children.append(hiveItem)
        }
    }
}
