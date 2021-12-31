import Foundation
import ObjectMapper

public class ClientConfig: Mappable {
    public var userConfig: UserConfig
    public var crossConfig: CrossConfig
    public var resolverUrl: String
    public var nodeConfig: NodeConfig
    public var applicationConfig: ApplicationConfig
    
    public required init?(map: Map) {
        try! self.userConfig = map.value("user")
        try! self.crossConfig = map.value("cross")
        try! self.nodeConfig = map.value("node")
        try! self.resolverUrl = map.value("resolverUrl")
        try! self.applicationConfig = map.value("application")
    }
    
    public func mapping(map: Map) {
        userConfig <- map["user"]
        crossConfig <- map["cross"]
        nodeConfig <- map["node"]
        resolverUrl <- map["resolverUrl"]
        applicationConfig <- map["application"]
    }
}
