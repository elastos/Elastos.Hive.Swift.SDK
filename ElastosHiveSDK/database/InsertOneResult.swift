
import UIKit

public class InsertOneResult: Result {
    private var _acknowledged: Bool = false

    public func insertedId() -> String? {
        let id = get("inserted_id")?.stringValue
        return id
    }

    public var acknowledged: Bool {
        return _acknowledged
    }

    public func deserialize(_ content: String) {
        // TODO:
    }
}

