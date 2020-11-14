
import UIKit

public class InsertOneResult: Result {
    private var _acknowledged: Bool?

    public func insertedId() -> String? {
        let id = get("inserted_id")?.stringValue
        return id
    }

    public var acknowledged: Bool? {
        return get("acknowledged")?.boolValue
    }

    public class func deserialize(_ content: String) throws -> InsertOneResult {
        let data = content.data(using: String.Encoding.utf8)
        let paramars = try JSONSerialization.jsonObject(with: data!,
                                                        options: .mutableContainers) as? [String : Any] ?? [: ]
        let opt = InsertOneResult(JSON(paramars))
        return opt
    }
}

