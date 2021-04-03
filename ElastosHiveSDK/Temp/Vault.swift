/*
* Copyright (c) 2019 Elastos Foundation
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

public class Vault: ServiceEndpoint {
    private var _filesService: FilesProtocol?
    private var _databaseService: DatabaseProtocol?
    private var _scripting: ScriptingProtocol?
    private var _pubsubService: PubSubProtocol?
    private var _backupService: BackupProtocol?
    private var _nodeManageService: NodeManageService?

    public init (_ context: AppContext,_ myDid: String, _ providerAddress: String) {
        super.init(context, providerAddress, myDid, myDid, nil)
        self._filesService = ServiceBuilder(self).createFilesService()
        self._databaseService = ServiceBuilder(self).createDatabase()
        self._scripting = ServiceBuilder(self).createScriptingService()
        self._pubsubService = ServiceBuilder(self).createPubsubService()
        self._backupService = ServiceBuilder(self).createBackupService()
        self._nodeManageService = NodeManageService(self)
    }
    
    public var filesService: FilesProtocol {
        return self._filesService!
    }
    
    public var databaseService: DatabaseProtocol {
        return self._databaseService!
    }

    public var scripting: ScriptingProtocol {
        return self._scripting!
    }
    
    public var pubSubService: PubSubProtocol {
        return self._pubsubService!
    }
    
    public var backupService: BackupProtocol {
        return self._backupService!
    }
    
    public override var connectionManager: ConnectionManager {
        return self.context.connectionManager
    }
    
    var appContext: AppContext {
        return self.context
    }
    
    public func getVersion() -> Promise<String> {
        return self._nodeManageService!.getVersion()
    }
    
    public func getCommitHash() -> Promise<String> {
        return self._nodeManageService!.getCommitHash()
    }
}


private class NodeManageService {
    private var _connectionManager: ConnectionManager

    public init (_ vault: Vault) {
        self._connectionManager = vault.appContext.connectionManager
    }

    public func getVersion() -> Promise<String> {
        return Promise<Any>.async().then { _ -> Promise<String> in
            return Promise<String> { resolver in
                let response = try HiveAPi.request(url: self._connectionManager.hiveApi.version(),
                                                   headers:try self._connectionManager.headers()).get(NodeVersionResponse.self)
                resolver.fulfill(response.version)
            }
        }
    }

    public func getCommitHash() -> Promise<String> {
        return Promise<Any>.async().then { _ -> Promise<String> in
            return Promise<String> { resolver in
                let response = try HiveAPi.request(url: self._connectionManager.hiveApi.commitHash(),
                                                   headers:try self._connectionManager.headers()).get(NodeCommitHashResponse.self)
                resolver.fulfill(response.commitHash)
            }
        }
    }
}
