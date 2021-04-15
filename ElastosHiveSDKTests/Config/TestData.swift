import Foundation
@testable import ElastosHiveSDK
import ElastosDIDSDK
import PromiseKit

public enum EnvironmentType: Int {
    case DEVELOPING
    case PRODUCTION
    case LOCAL
}

public class TestBackupRender: BackupContext {
    public var nodeConfig: NodeConfig
    public var userDid: DIDApp?
    public var _type: String?
    public var type: String {
        get {
            return _type!
        }
        set {
            _type = newValue
        }
    }

    public init(_ userDid: DIDApp, _ vault: Vault, _ nodeConfig: NodeConfig) {
        self.userDid = userDid
        self.nodeConfig = nodeConfig
    }
    
    public func getParameter(_ key: String) -> String {
        if key == "targetDid" {
            return self.nodeConfig.targetDid
        } else if key == "targetHost" {
            return self.nodeConfig.targetHost
        }
        return ""
    }
    
    public func getAuthorization(_ srcDid: String, _ targetDid: String, _ targetHost: String) -> Promise<String> {
        Promise<Any>.async().then { [self] _ -> Promise<String> in
            return Promise<String> { resolver in
                let auth = try userDid!.issueBackupDiplomaFor(srcDid, targetHost, targetDid)
                resolver.fulfill(auth.description)
            }
        }
    }
    
}

/**
 * This is used for representing 3rd-party application.
 */

public class TestData {
    static let shared: TestData = try! TestData()
    
    public var userDid: DIDApp?
    public var userDidCaller: DIDApp?;
    public var callerDid: String?
    public var appInstanceDid: DApp?
    public var nodeConfig: NodeConfig
    public var context: AppContext?
    public var contextCaller: AppContext?

    public var providerAddress: String {
        set {
            self.nodeConfig.provider = newValue
        }
        get {
            return self.nodeConfig.provider
        }
    }
    
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
        
        guard let _ = file else {
            throw DIDError.illegalArgument("Couldn't find a PEM file named \(file!)")
        }
        let jsonData = try Data(contentsOf: URL(fileURLWithPath: file!))
        let json = try JSONSerialization.jsonObject(with: jsonData)
        print(json)

        let clientConfig = ClientConfig(JSON: json as! [String : Any])
        
        try AppContext.setupResover(clientConfig!.resolverUrl, "data/didCache")
        let adapter = DummyAdapter()
        let applicationConfig = clientConfig!.application
        appInstanceDid = try DApp(applicationConfig.name, applicationConfig.mnemonic,  adapter,applicationConfig.passPhrase, applicationConfig.storepass)
        let userConfig = clientConfig!.user
        self.userDid = DIDApp(userConfig.name, userConfig.mnemonic, adapter, userConfig.passPhrase, userConfig.storepass)
        self.nodeConfig = clientConfig!.nodeConfig
        let storePath = "\(NSHomeDirectory())/Library/Caches/data/store" + "/" + self.nodeConfig.storePath

        let appContextProvider = UserAppContextProvider(storePath, userDid!, appInstanceDid!)
        self.context = try AppContext.build(appContextProvider, nodeConfig.ownerDid)
        
    }
    
    public var appContext: AppContext? {
        return self.context
    }
    
    public var ownerDid: String {
        return self.nodeConfig.ownerDid
    }
        
    public func newVault() -> Vault {
        return Vault(self.context!, self.nodeConfig.provider, nil, nil)
    }
    
    public func newVault4Scripting() -> Vault {
        return Vault(self.context!, self.nodeConfig.provider, self.nodeConfig.ownerDid, nil)
    }
    
    public func newBackup() -> Backup {
        return Backup(self.context!, self.nodeConfig.targetHost)
    }

    public func backupService() throws -> BackupServiceRender {
        let backService = self.newVault().backupService
        _ = try backService.setupContext(TestBackupRender(userDid!, self.newVault(), self.nodeConfig))
        return backService as! BackupServiceRender
    }
    
    public var appId: String {
        return self.appInstanceDid!.appId
    }
}
