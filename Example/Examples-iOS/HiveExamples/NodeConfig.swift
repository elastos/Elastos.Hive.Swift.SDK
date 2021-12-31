import Foundation
import ObjectMapper

public class NodeConfig: Mappable {
    public var provider: String
    public var targetDid: String
    public var storePath: String
    public var targetHost: String
    
    required public init?(map: Map) {
        try! self.provider = map.value("provider")
        try! self.storePath = map.value("storePath")
        try! self.targetDid = map.value("targetDid")
        try! self.targetHost = map.value("targetHost")
    }
    
    public func mapping(map: Map) {
        provider <- map["provider"]
        storePath <- map["storePath"]
        targetDid <- map["targetDid"]
        targetHost <- map["targetHost"]
    }
    
}

