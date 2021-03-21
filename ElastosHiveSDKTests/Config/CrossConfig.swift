import Foundation
import ObjectMapper

public class CrossConfig: Mappable {
    
    public var application: ApplicationConfig?
    public var user: UserConfig?
    public var crossDid: String?
    
//    init(_ application: ApplicationConfig, _ user: UserConfig, _ crossDid: String) {
//        self.application = application
//        self.user = user
//        self.crossDid = crossDid
//    }
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        application <- map["application"]
        user <- map["user"]
        crossDid <- map["crossDid"]
    }
}
