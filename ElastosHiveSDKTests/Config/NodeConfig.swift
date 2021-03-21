import Foundation
import ObjectMapper

public class NodeConfig: Mappable {
    public var ownerDid: String?
    public var provider: String?
    public var targetDid: String?
    public var targetHost: String?
    public var storePath: String?
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        ownerDid <- map["ownerDid"]
        provider <- map["provider"]
        targetDid <- map["targetDid"]
        targetHost <- map["targetHost"]
        storePath <- map["storePath"]
    }
    
}

