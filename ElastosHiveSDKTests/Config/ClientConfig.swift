import Foundation
import ObjectMapper

public class ClientConfig: Mappable {
    public var resolverUrl: String
    public var application: ApplicationConfig
    public var user: UserConfig
    public var nodeConfig: NodeConfig
    public var cross: CrossConfig
    
    public required init?(map: Map) {
        try! self.resolverUrl = map.value("resolverUrl")
        try! self.application = map.value("application")
        try! self.user = map.value("user")
        try! self.nodeConfig = map.value("node")
        try! self.cross = map.value("cross")
    }
    
    public func mapping(map: Map) {
        resolverUrl <- map["resolverUrl"]
        application <- map["application"]
        user <- map["user"]
        nodeConfig <- map["node"]
        cross <- map["cross"]
    }
}
