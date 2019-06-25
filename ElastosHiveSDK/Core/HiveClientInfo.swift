import Foundation

public class HiveClientInfo: AttributeMap {
    public static let userId: String = "UserId"
    public static let name: String = "DisplayName"
    public static let email: String = "Email"
    public static let phoneNo: String = "PhoneNo"
    public static let region: String = "Region"
    override init(_ hash: Dictionary<String, String>) {
        super.init(hash)
    }
}
