import Foundation

public class AttributeMap: Result {

    ///  The `AttributeMap` object is a property bag for itemInfo information.
    var attrDic: Dictionary<String, String>?
    init(_ dic: Dictionary<String, String>) {
        self.attrDic = dic
    }

    /// Get itemInfo value for key
    ///
    /// - Returns: Returns the value information for the itemInfo
    public func getValue(_ key: String) -> String {
        return self.attrDic![key] ?? ""
    }
}
