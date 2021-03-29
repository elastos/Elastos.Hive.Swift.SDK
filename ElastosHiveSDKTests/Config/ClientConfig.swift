import Foundation
import ObjectMapper

public class ClientConfig: Mappable {
    public var user: UserConfig
    public var cross: CrossConfig
    public var resolverUrl: String
    public var nodeConfig: NodeConfig
    public var application: ApplicationConfig
    
    public required init?(map: Map) {
        try! self.user = map.value("user")
        try! self.cross = map.value("cross")
        try! self.nodeConfig = map.value("node")
        try! self.resolverUrl = map.value("resolverUrl")
        try! self.application = map.value("application")
    }
    
    public func mapping(map: Map) {
        user <- map["user"]
        cross <- map["cross"]
        nodeConfig <- map["node"]
        resolverUrl <- map["resolverUrl"]
        application <- map["application"]
    }
}
