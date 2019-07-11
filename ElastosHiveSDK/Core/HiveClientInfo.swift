import Foundation

///  The `HiveClientInfo` object is a property bag for ClientInfo information.
public class HiveClientInfo: AttributeMap {

    /// The unique identifier for the user.
    public static let userId: String = "UserId"


    /// The name displayed in the address book for the user.
    /// This is usually the combination of the user's first name, middle initial and last name.
    /// This property is required when a user is created and it cannot be cleared during updates.
    /// Supports $filter and $orderby.
    public static let name:   String = "DisplayName"

    /// The SMTP address for the user,
    /// for example, "jeff@contoso.onmicrosoft.com". Read-Only. Supports $filter.
    public static let email:  String = "Email"

    /// The primary cellular telephone number for the user.
    public static let phoneNo:String = "PhoneNo"

    /// The office location in the user's place of business.
    public static let region: String = "Region"


    /// Create a `HiveClientInfo` instance
    ///
    /// - Parameter dict: The dictionary with the `name`, `email`, `phoneNo` and `region` key-value
    override init(_ dict: Dictionary<String, String>) {
        super.init(dict)
    }
}
