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

public class BackupServiceRender: BackupProtocol {
    var vault: Vault
    var backupContext: BackupContext?
    var connectionManager: ConnectionManager?
    var tokenResolver: TokenResolver?

    public init(_ vault: Vault) {
        self.vault = vault
        self.connectionManager = self.vault.connectionManager
    }
    
    public func setupContext(_ backupContext: BackupContext) throws -> Promise<Void> {
        return Promise<Void> { resolver in
            self.backupContext = backupContext
            self.tokenResolver = try LocalResolver(self.vault.context.userDid!, self.vault.context.providerAddress!, "backup_credential", self.vault.context.appContextProvider.getLocalDataDir()!)
            let remoteResolver: RemoteResolver = RemoteResolver(self.vault.context,
                                                                backupContext,
                                                                backupContext.getParameter("targetDid"),
                                                                backupContext.getParameter("targetHost"))
            self.tokenResolver?.setNextResolver(remoteResolver)
            resolver.fulfill(Void())
        }
    }
    
    public func startBackup() throws -> Promise<Void> {
        return Promise<Void> { resolver in
            let url = self.connectionManager!.hiveApi.saveToNode()
            let header = try self.connectionManager?.headers()
            let credential: String = try self.tokenResolver!.getToken()!._accessToken
            let param: Parameters = ["backup_credential": credential]
            let json = try! AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header).responseJSON().validateResponse()
            resolver.fulfill(Void())
        }
    }
    
    public func stopBackup() -> Promise<Void> {
        return Promise<Void> { resolver in
            resolver.fulfill(Void())
        }
    }
    
    public func restoreFrom() throws -> Promise<Void> {
        return Promise<Any>.async().then {[self] _ -> Promise<Void> in
            return Promise<Void> { resolver in
                let url = self.connectionManager!.hiveApi.restoreFromNode()
                let header = try self.connectionManager?.headers()
                let credential: String = try self.tokenResolver!.getToken()!._accessToken
                let param: Parameters = ["backup_credential": credential]
                _ = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header).responseJSON()
                resolver.fulfill(Void())
            }
        }
    }
    
    public func stopRestore() -> Promise<Void> {
        return Promise<Void> { resolver in
            resolver.fulfill(Void())
        }
    }
    
    public func checkResult() throws -> Promise<BackupResult> {
        return Promise<BackupResult> { resolver in
            let url = self.connectionManager!.hiveApi.getState()
            let header = try self.connectionManager?.headers()
            let json = try AF.request(url, method: .get, encoding: JSONEncoding.default, headers: header).responseJSON().validateResponse()
            let result = json["result"].stringValue
            if result != "success" {
                throw HiveError.failedToGetBackupState
            }
            
            let type = json["hive_backup_state"].stringValue
            switch (type) {
            case "stop":
                resolver.fulfill(BackupResult.stop)
            case "backup":
                resolver.fulfill(BackupResult.backup)
            case "restore":
                resolver.fulfill(BackupResult.restore)
            default:
                throw HiveError.hiveDefaultError(des: "Unknown state :" + result)
            }
        }
    }
}
