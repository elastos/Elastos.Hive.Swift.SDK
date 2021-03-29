import Foundation
import ObjectMapper

public class CrossConfig: Mappable {
    public var user: UserConfig
    public var crossDid: String
    public var application: ApplicationConfig
    
    required public init?(map: Map) {
        try! self.user = map.value("user")
        try! self.crossDid = map.value("crossDid")
        try! self.application = map.value("application")
    }
    
    public func mapping(map: Map) {
        user <- map["user"]
        crossDid <- map["crossDid"]
        application <- map["application"]
    }
}
