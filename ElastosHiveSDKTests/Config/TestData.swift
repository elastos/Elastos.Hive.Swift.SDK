import Foundation
@testable import ElastosHiveSDK
import ElastosDIDSDK
import PromiseKit

public enum EnvironmentType: Int {
    case DEVELOPING
    case PRODUCTION
    case LOCAL
}

public class TestData {
    
    static let shared: TestData = try! TestData()
    public var userDid: DIDApp?
    public var appInstanceDid: DApp?
    public var nodeConfig: NodeConfig?
    public var appContext: AppContext?
    public var providerAddress: String? {
        set {
            self.nodeConfig?.provider = newValue!
        }
        get {
            return self.nodeConfig?.provider
        }
    }
    
//    public static var testData: TestData {
//        return try! TestData()
//    }
    
    public init () throws {
        var file: String? = nil
        let bundle = Bundle(for: type(of: self))
        switch EnvironmentType.DEVELOPING {
        case .DEVELOPING:
            file = bundle.path(forResource: "Developing", ofType: "conf")
        case .PRODUCTION:
            file = bundle.path(forResource: "Production", ofType: "conf")
        case .LOCAL:
            file = bundle.path(forResource: "Local", ofType: "conf")
        }
        print(file)
        
        guard let _ = file else {
            throw DIDError.illegalArgument("Couldn't find a PEM file named \(file)")
        }
        let jsonData = try Data(contentsOf: URL(fileURLWithPath: file!))
        let json = try JSONSerialization.jsonObject(with: jsonData)
        print(json)

        let clientConfig = ClientConfig(JSON: json as! [String : Any])
        
        try AppContext.setupResover(clientConfig!.resolverUrl, "data/didCache")
        let adapter = DummyAdapter()
        let applicationConfig = clientConfig!.application
        appInstanceDid = try DApp(applicationConfig.name!, applicationConfig.mnemonic!,  adapter,applicationConfig.passPhrase!, applicationConfig.storepass!)
        let userConfig = clientConfig!.user
        self.userDid = DIDApp(userConfig.name!, userConfig.mnemonic!, adapter, userConfig.passPhrase!, userConfig.storepass!)
        self.nodeConfig = clientConfig!.nodeConfig
        let storePath = "\(NSHomeDirectory())/Library/Caches/data/store" + "/" + nodeConfig!.storePath!

        self.appContext = try AppContext.build(UserAppContextProvider(storePath, userDid!, appInstanceDid!), (nodeConfig?.ownerDid)! as String, (nodeConfig?.provider)! as String)
//        self.appContext = try AppContext.build(UserAppContextProvider(storePath, userDid!, appInstanceDid!), nodeConfig?.ownerDid, nodeConfig?.provider) as! AppContext
    }

    public var ownerDid: String? {
        get {
            return self.nodeConfig?.ownerDid
        }
    }
    
//    class func shared() -> TestData {
//        return testData
//    }
    
    public func newVault() -> Vault {
        return Vault(appContext!, nodeConfig!.ownerDid!, nodeConfig!.provider!)
    }
    
    public var getAppContext: AppContext? {
        return self.appContext
    }
    
    public var getOwnerDid: String? {
        return nodeConfig!.ownerDid
    }
    
    public var getProviderAddress: String? {
        return nodeConfig!.provider
    }
    
    public func getVault() -> Promise<Vault> {
        return appContext!.getVault(nodeConfig!.ownerDid!, nodeConfig!.provider!)
    }
}
