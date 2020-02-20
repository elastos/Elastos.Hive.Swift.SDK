
public protocol Persistent {
    func parseFrom() -> Dictionary<String, Any>
    func upateContent(_ json: Dictionary<String, Any>)
}
