import Foundation

public class AttributeMap: NSObject {
    var attrDic: Dictionary<String, String>?
    init(_ dic: Dictionary<String, String>) {
        self.attrDic = dic
    }
}
