import Foundation
import ObjectMapper

public class UserConfig: Mappable {
    public var did: String
    public var name: String
    public var mnemonic: String
    public var storepass: String
    public var passPhrase: String
    
    required public init?(map: Map) {
        try! self.did = map.value("did")
        try! self.name = map.value("name")
        try! self.mnemonic = map.value("mnemonic")
        try! self.storepass = map.value("storepass")
        try! self.passPhrase = map.value("passPhrase")
    }

    public func mapping(map: Map) {
        did <- map["did"]
        name <- map["name"]
        mnemonic <- map["mnemonic"]
        passPhrase <- map["passPhrase"]
        storepass <- map["storepass"]
    }
}
