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
        if key == "targetAddress" {
            return self.nodeConfig.targetHost
        } else if key == "targetServiceDid" {
            return self.nodeConfig.targetDid
        }
        return ""
    }
    
    public func getAuthorization(_ srcDid: String, _ targetDid: String, _ targetHost: String) -> Promise<String> {
        return Promise<String> { resolver in
            do {
                let auth = try userDid!.issueBackupDiplomaFor(srcDid, targetHost, targetDid)
                resolver.fulfill(auth.description)
            } catch {
                resolver.reject(error)
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
    public var _callerDid: String?
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
    
    public init() throws {
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

        let jsonData = try Data(contentsOf: URL(fileURLWithPath: file!))
        let json = try JSONSerialization.jsonObject(with: jsonData)

        let clientConfig = ClientConfig(JSON: json as! [String : Any])
        
        try AppContext.setupResover(clientConfig!.resolverUrl, "data/didCache")
        let adapter = DummyAdapter()
        let applicationConfig = clientConfig!.applicationConfig
        appInstanceDid = try DApp(applicationConfig.name, applicationConfig.mnemonic,  adapter,applicationConfig.passPhrase, applicationConfig.storepass)
        let userConfig = clientConfig!.userConfig
        self.userDid = DIDApp(userConfig.name, userConfig.mnemonic, adapter, userConfig.passPhrase, userConfig.storepass)
        self.nodeConfig = clientConfig!.nodeConfig
        
        let userConfigCaller: UserConfig = clientConfig!.crossConfig.userConfig
        self.userDidCaller = DIDApp(userConfigCaller.name, userConfigCaller.mnemonic, adapter, userConfigCaller.passPhrase, userConfigCaller.storepass)

        
        let storePath = "\(NSHomeDirectory())/Library/Caches/data/store" + "/" + self.nodeConfig.storePath
        self.context = try AppContext.build(TestAppContextProvider(storePath, userDid!, appInstanceDid!),
                                            nodeConfig.ownerDid)
        self.contextCaller = try AppContext.build(TestAppContextProvider(storePath, userDid!, appInstanceDid!),
                                            nodeConfig.ownerDid)
        
        _callerDid = userConfigCaller.did
    }
    
    public var appContext: AppContext {
        return self.context!
    }
    
    public var ownerDid: String {
        return self.nodeConfig.ownerDid
    }
        
    public func newVault() throws -> Vault {
        return try Vault(self.context!, self.nodeConfig.provider)
    }
    
    public func newScriptRunner() throws -> ScriptRunner {
        return try ScriptRunner(context!, nodeConfig.provider)
    }
    
    public func newCallerScriptRunner() throws -> ScriptRunner {
        return try ScriptRunner(self.contextCaller!, nodeConfig.provider)
    }
    
    public func newBackup() throws -> Backup {
        return try Backup(self.context!, self.nodeConfig.targetHost)
    }
    
    public func backupService() throws -> BackupServiceRender {
        let backService = try self.newVault().backupService
        _ = try backService.setupContext(TestBackupRender(userDid!, self.newVault(), self.nodeConfig))
        return backService as! BackupServiceRender
    }
    
    public var appId: String {
        return self.appInstanceDid!.appId
    }
    
    public var callerDid: String {
        return self._callerDid!
    }
}
