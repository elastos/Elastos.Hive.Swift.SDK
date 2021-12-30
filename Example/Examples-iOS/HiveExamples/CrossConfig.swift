import Foundation
import ObjectMapper

public class CrossConfig: Mappable {
    public var userConfig: UserConfig
    public var crossDid: String
    public var application: ApplicationConfig
    
    required public init?(map: Map) {
        try! self.userConfig = map.value("user")
        try! self.crossDid = map.value("crossDid")
        try! self.application = map.value("application")
    }
    
    public func mapping(map: Map) {
        userConfig <- map["user"]
        crossDid <- map["crossDid"]
        application <- map["application"]
    }
}
