import Foundation
@testable import ElastosHiveSDK
import PromiseKit
import DeveloperDID

public enum EnvironmentType: Int {
    case DEVELOPING
    case PRODUCTION
    case LOCAL
}

/// This is used for representing 3rd-party application.
public class TestData {
    private static var instance: TestData?
    private let RESOLVE_CACHE = "data/didCache"
    private var _network: String!
    private var _userDid: UserDID!
    private var _callerDid: UserDID!
    private var _appInstanceDid: AppDID!
    private var _appInstanceDidDoc: DIDDocument!
    private var _nodeConfig: NodeConfig!
    private var _applicationConfig: ApplicationConfig!
    private var _context: AppContext!
    private var _callerContext: AppContext!
    private var _storePath: String!
    private var _ipfsGatewayUrl = ""
    public static func shared() -> TestData {
        if (instance == nil) {
            instance = TestData()
        }
        return instance!
    }
    
    public init() {
        do {
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
            self._network = clientConfig!.resolverUrl
            try AppContext.setupResover(clientConfig!.resolverUrl, "data/didCache")
            _ipfsGatewayUrl = clientConfig!.ipfsGateUrl

            _applicationConfig = clientConfig!.applicationConfig
            _appInstanceDid = try AppDID(_applicationConfig.name, _applicationConfig.mnemonic, _applicationConfig.passPhrase, _applicationConfig.storepass, _network)
            _appInstanceDidDoc = try _appInstanceDid.getDocument()
            
            let userConfig = clientConfig!.userConfig
            _userDid = try UserDID(userConfig.name, userConfig.mnemonic, userConfig.passPhrase, userConfig.storepass, _network)
            _nodeConfig = clientConfig!.nodeConfig
            
            
            _storePath = "\(NSHomeDirectory())/Library/Caches/data/store" + "/" + _nodeConfig.storePath
            _context = try AppContext.build(TestAppContextProvider(_storePath, _userDid, _appInstanceDid), _userDid.description, appId)
            
             let userConfigCaller: UserConfig = clientConfig!.crossConfig.userConfig
            _callerDid = try UserDID(userConfigCaller.name, userConfigCaller.mnemonic, userConfigCaller.passPhrase, userConfigCaller.storepass, _network)
                        
            _nodeConfig = clientConfig!.nodeConfig
            
            //初始化Application Context
            
            _callerContext = try AppContext.build(TestAppContextProvider(_storePath, _userDid, _appInstanceDid), _userDid.description, appId)
        }
        catch {
            print(error)
        }
    }
    
    public var storePath: String {
        return _storePath
    }
    
    public var appContext: AppContext {
        return _context
    }
    
    public var providerAddress: String {
        set {
            _nodeConfig.provider = newValue
        }
        get {
            return _nodeConfig.provider
        }
    }
    
    public var backupProviderAddress: String {
        set {
            _nodeConfig.targetHost = newValue
        }
        get {
            return _nodeConfig.targetHost
        }
    }
    
    public func getEncryptionCipher() throws -> DIDCipher {
        return try self._appInstanceDidDoc.createCipher(self.appId, 6, self._applicationConfig.storepass)
    }

    public func getEncryptionDatabaseService() throws -> DatabaseService {
        let vault = try self.newVault()
        do {
            try vault.enableEncryption(self._applicationConfig.storepass)
        } catch {
            print(error)
        }
        return try vault.getDatabaseService(encrypt: true)
    }
    
    public func getEncryptionFileService() throws -> FilesService {
        let vault = try self.newVault()
        do {
            try vault.enableEncryption(self._applicationConfig.storepass)
        } catch {
            print(error)
        }
        return try vault.getFilesService(encrypt: true)
    }
 
    public func newVault() throws -> Vault {
        return try Vault(_context, providerAddress)
    }
    
    public func newVaultSubscription() throws -> VaultSubscription {
        return try VaultSubscription(_context, providerAddress)
    }

    public func newScriptRunner() throws -> ScriptRunner {
        return try ScriptRunner(_callerContext, providerAddress)
    }
    
    
    public func newCallerScriptRunner() throws -> ScriptRunner {
        return try ScriptRunner(_callerContext, providerAddress)
    }
    
    public func newBackup() throws -> Backup {
        return try Backup(_context, _nodeConfig.targetHost)
    }
    
    public func newBackupSubscription() throws -> BackupSubscription {
        return try BackupSubscription(_context, backupProviderAddress)
    }
    
    public func getIpfsGatewayUrl() -> String {
        return self._ipfsGatewayUrl
    }

    
    public func backupService() throws -> BackupServiceRender {
        let backService = try newVault().backupService
        _ = try backService.setupContext(TestBackupRender(_userDid, newVault(), _nodeConfig))
        return backService as! BackupServiceRender
    }
    
    public var appId: String {
        return _appInstanceDid.appId
    }
    
    public var userDid: String {
        return _userDid.description
    }
       
    public var callerDid: String {
        return _callerDid.description
    }
}

public class TestBackupRender: BackupContext {    
    public var nodeConfig: NodeConfig
    public var userDid: UserDID
    public var _type: String?
    
    public func getType() -> String? {
        return _type
    }
    
    public func getAuthorization(_ srcDid: String?, _ targetDid: String?, _ targetHost: String?) -> Promise<String>? {
        return Promise<String> { resolver in
            let auth = try userDid.issueBackupDiplomaFor(srcDid!, targetHost!, targetDid!)
            resolver.fulfill(auth.toString(true))
        }
    }

    public init(_ userDid: UserDID, _ vault: Vault, _ nodeConfig: NodeConfig) {
        self.userDid = userDid
        self.nodeConfig = nodeConfig
    }
    
    public func getParameter(_ key: String) -> String? {
        if key == "targetDid" {
            return self.nodeConfig.targetDid
        } else if key == "targetHost" {
            return self.nodeConfig.targetHost
        }
        return ""
    }
}
