import Foundation
import ObjectMapper

public class UserConfig: Mappable {
    
    public var did: String?
    public var name: String?
    public var mnemonic: String?
    public var passPhrase: String?
    public var storepass: String?
    
//    init(_ did: String, _ name: String, _ mnemonic: String, _ passPhrase: String, _ storepass: String) {
//        self.did = did
//        self.name = name
//        self.mnemonic = mnemonic
//        self.passPhrase = passPhrase
//        self.storepass = storepass
//    }
    
    required public init?(map: Map) {}

    public func mapping(map: Map) {
        did <- map["did"]
        name <- map["name"]
        mnemonic <- map["mnemonic"]
        passPhrase <- map["passPhrase"]
        storepass <- map["storepass"]
    }
}
