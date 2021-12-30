import Foundation
import ObjectMapper

public class ApplicationConfig: Config {
    public var name: String!
    public var mnemonic: String!
    public var storepass: String!
    public var passPhrase: String!

    required public init?(map: Map) {
        try! name = map.value("name")
        try! mnemonic = map.value("mnemonic")
        try! storepass = map.value("storepass")
        try! passPhrase = map.value("passPhrase")
        super.init(map: map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        name <- map["name"]
        mnemonic <- map["mnemonic"]
        storepass <- map["storepass"]
        passPhrase <- map["passPhrase"]
    }
}
