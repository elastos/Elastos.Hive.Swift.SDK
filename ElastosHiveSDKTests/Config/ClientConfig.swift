import Foundation
import ObjectMapper

public class ClientConfig: Mappable {
    
    public var resolverUrl: String?
    public var application: ApplicationConfig?
    public var user: UserConfig?
    public var nodeConfig: NodeConfig?
    public var cross: CrossConfig?
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        resolverUrl <- map["resolverUrl"]
        application <- map["application"]
        user <- map["user"]
        nodeConfig <- map["node"]
        cross <- map["cross"]
    }
}
