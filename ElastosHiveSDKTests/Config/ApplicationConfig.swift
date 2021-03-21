import Foundation
import ObjectMapper

public class ApplicationConfig: Mappable {
    
    public var name: String?
    public var mnemonic: String?
    public var passPhrase: String?
    public var storepass: String?

//    init(_ name: String, _ mnemonic: String, _ passPhrase: String, _ storepass: String) {
//        self.name = name
//        self.mnemonic = mnemonic
//        self.passPhrase = passPhrase
//        self.storepass = storepass
//    }
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        name <- map["name"]
        mnemonic <- map["mnemonic"]
        passPhrase <- map["passPhrase"]
        storepass <- map["storepass"]
    }
    
}
