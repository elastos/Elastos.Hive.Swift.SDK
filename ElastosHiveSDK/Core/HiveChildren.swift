import Foundation

public class HiveChildren: Result {
    public var children: Array<ItemInfo>

    public override init() {
        children = []
    }

    func installValue(_ jsonData: JSON) {
        let childrenData = jsonData["value"].arrayValue
        print(childrenData)
        for it in childrenData {
            let folder = it["folder"].stringValue
            var type = folder
            if folder == "" {
                type = "file"
            }
            let dic = [ItemInfo.itemId: it["id"].stringValue,
                       ItemInfo.name: it["name"].stringValue,
                       ItemInfo.size: it["size"].stringValue,
                       ItemInfo.type: type]
            let item = ItemInfo(dic)
            children.append(item)
        }

    }
}
