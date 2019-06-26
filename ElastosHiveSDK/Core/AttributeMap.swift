import Foundation

public class AttributeMap: Result {
    var attrDic: Dictionary<String, String>?
    init(_ dic: Dictionary<String, String>) {
        self.attrDic = dic
    }
}
