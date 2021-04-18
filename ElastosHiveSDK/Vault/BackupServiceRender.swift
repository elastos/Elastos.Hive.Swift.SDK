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

public class BackupServiceRender: HiveVaultRender, BackupProtocol {
    var _backupContext: BackupContext?
    var _tokenResolver: TokenResolver?
    
    public func setupContext(_ backupContext: BackupContext) throws -> Promise<Void> {
        return Promise<Any>.async().then{ [self] _ -> Promise<Void> in
            return Promise<Void> { resolver in
                self._backupContext = backupContext
                self._tokenResolver = try LocalResolver(self.serviceEndpoint.userDid!,
                                                        self.serviceEndpoint.providerAddress,
                                                        LocalResolver.TYPE_BACKUP_CREDENTIAL,
                                                        self.serviceEndpoint.appContext.appContextProvider.getLocalDataDir()!)
                let backupRemoteResolver: BackupRemoteResolver = BackupRemoteResolver(self.serviceEndpoint,
                                                                                      backupContext,
                                                                                      backupContext.getParameter("targetDid"),
                                                                                      backupContext.getParameter("targetHost"))
                try! self._tokenResolver?.setNextResolver(backupRemoteResolver)
                resolver.fulfill(Void())
            }
        }
    }
    
    public func startBackup() -> Promise<Void> {
        return Promise<Any>.async().then{ [self] _ -> Promise<Void> in
            return Promise<Void> { resolver in
                do {
                    let url = self.connectionManager.hiveApi.saveToNode()
                    let header = try self.connectionManager.headers()
                    let credential: String = try self._tokenResolver!.getToken()!.accessToken
                    let param: Parameters = ["backup_credential": credential]
                    _ = try HiveAPi.request(url: url, method: .post, parameters: param, headers: header).get(HiveResponse.self)
                    resolver.fulfill(Void())
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }

    public func stopBackup() -> Promise<Void> {
        return Promise<Void> { resolver in
            throw HiveError.UnsupportedOperationException
        }
    }
    
    public func restoreFrom() -> Promise<Void> {
        return Promise<Any>.async().then {[self] _ -> Promise<Void> in
            return Promise<Void> { resolver in
                let url = self.connectionManager.hiveApi.restoreFromNode()
                let header = try self.connectionManager.headers()
                let credential: String = try self._tokenResolver!.getToken()!.accessToken
                let param: Parameters = ["backup_credential": credential]
                _ = try HiveAPi.request(url: url, method: .post, parameters: param, headers: header).get(HiveResponse.self)
                resolver.fulfill(Void())
            }
        }
    }
    
    public func stopRestore() -> Promise<Void> {
        return Promise<Any>.async().then { _ -> Promise<Void> in
            return Promise<Void> { resolver in
                resolver.fulfill(Void())
            }
        }
    }
    
    public func checkResult() -> Promise<BackupResult> {
        return Promise<Any>.async().then {[self] _ -> Promise<BackupResult> in
            return Promise<BackupResult> { resolver in
                let url = self.connectionManager.hiveApi.getState()
                let header = try self.connectionManager.headers()
                let response = try HiveAPi.request(url: url, method: .get, headers: header).get(BackupStateResponse.self)
                resolver.fulfill(try response.getStatusResult())
            }
        }
    }
}
