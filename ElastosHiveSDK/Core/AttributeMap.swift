import Foundation

public class AttributeMap: Result {
    var attrDic: Dictionary<String, String>?
    init(_ dic: Dictionary<String, String>) {
        self.attrDic = dic
    }

    public func getValue(_ key: String) -> String {
        return self.attrDic![key] ?? ""
    }
}
