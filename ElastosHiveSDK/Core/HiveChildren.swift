import Foundation

public class HiveChildren: Result {
    public var children: Array<HiveItemInfo>

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
            let dic = [HiveItemInfo.itemId: it["id"].stringValue,
                       HiveItemInfo.name: it["name"].stringValue,
                       HiveItemInfo.size: String(it["size"].int64Value),
                       HiveItemInfo.type: type]
            let item = HiveItemInfo(dic)
            children.append(item)
        }

    }
}
