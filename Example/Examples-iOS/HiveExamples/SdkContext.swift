/*
* Copyright (c) 2020 Elastos Foundation
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import Foundation
import ElastosHiveSDK
import ElastosDIDSDK

public enum EnvironmentType: Int {
    case DEVELOPING
    case PRODUCTION
    case LOCAL
}

public final class SdkContext {
//    static let instance = {
//        try! SdkContext()
//    }()
    
    private var _userDid: UserDID
    private var _callerDid: UserDID
    private var _appInstanceDid: AppDID
    private var _nodeConfig: NodeConfig
    private var _context: AppContext
    private var _contextCaller: AppContext
    private var _storePath: String

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
        let applicationConfig = clientConfig!.applicationConfig
        _appInstanceDid = try AppDID(applicationConfig.name, applicationConfig.mnemonic, applicationConfig.passPhrase, applicationConfig.storepass)
        let userConfig = clientConfig!.userConfig
        _userDid = try UserDID(userConfig.name, userConfig.mnemonic, userConfig.passPhrase, userConfig.storepass)
        _nodeConfig = clientConfig!.nodeConfig
        
        let userConfigCaller: UserConfig = clientConfig!.crossConfig.userConfig
        _callerDid = try UserDID(userConfigCaller.name, userConfigCaller.mnemonic, userConfigCaller.passPhrase, userConfigCaller.storepass)
        
        
        _storePath = "\(NSHomeDirectory())/Library/Caches/data/store" + "/" + _nodeConfig.storePath
        _context = try AppContext.build(TestAppContextProvider(_storePath, _userDid, _appInstanceDid), _userDid.description)
        _contextCaller = try AppContext.build(TestAppContextProvider(_storePath, _callerDid, _appInstanceDid), _callerDid.description)
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
 
    public func newVault() -> Vault {
        return Vault(_context, providerAddress)
    }
    
    public func newScriptRunner() -> ScriptRunner {
        return ScriptRunner(_context, providerAddress)
    }
    
    public func newCallerScriptRunner() -> ScriptRunner {
        return ScriptRunner(_contextCaller, providerAddress)
    }
    
    public func newBackup() -> Backup {
        return Backup(_context, _nodeConfig.targetHost)
    }
    
    public func backupService() throws -> BackupServiceRender {
        let backService = newVault().backupService
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
