import Foundation
import ObjectMapper

public class ApplicationConfig: Config {
    public var name: String
    public var mnemonic: String
    public var storepass: String
    public var passPhrase: String

    required public init?(map: Map) {
        try! self.name = map.value("name")
        try! self.mnemonic = map.value("mnemonic")
        try! self.storepass = map.value("storepass")
        try! self.passPhrase = map.value("passPhrase")
    }
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        name <- map["name"]
        mnemonic <- map["mnemonic"]
        storepass <- map["storepass"]
        passPhrase <- map["passPhrase"]
    }
}
