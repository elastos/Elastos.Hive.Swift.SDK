import Foundation

public class HiveClientInfo: NSObject {
    public var userId: String
    public var displayName: String
    public var email: String
    public var phone: String
    public var region: String

    init(_ userId: String) {
        self.userId = userId
        self.displayName = ""
        self.email = ""
        self.phone = ""
        self.region = ""
        super.init()
    }

    func installValue(_ jsonData: JSON) {
        self.userId = jsonData["id"].stringValue
        self.displayName = jsonData["createdDateTime"].stringValue
        self.email = jsonData["email"].stringValue
        self.phone = jsonData["phone"].stringValue
        self.region = jsonData["region"].stringValue
    }
}
