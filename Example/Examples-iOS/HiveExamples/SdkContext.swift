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

public class HiveExampleBackupContext {
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

final class SdkContext {
    static let instance = SdkContext()
    
    private var _userDid: DIDApp?
    private var _userDidCaller: DIDApp?
    private var _callerDid: String?
    private var _appInstanceDid: DApp?
    private var _nodeConfig: NodeConfig?
    private var _context: AppContext?
    private var _contextCaller: AppContext?
    
    public init() {
       
    }
    
    
    private func getLocalRootDir() -> String {
        return ""
    }
    
    private func getLocalDidCacheDir(_ envName: String) -> String {
        return ""
    }
    
    private func getLocalDidStoreRootDir(_ envName: String) -> String {
        return ""
    }
    
    public var appContext: AppContext {
        return self._context!
    }
    
    public var ownerDid: String {
        return self._nodeConfig!.ownerDid
    }
    
    public var providerAddress: String {
        return self._nodeConfig!.provider
    }
    
    public func newVault() throws -> Vault {
        return try Vault(self._context!, _nodeConfig!.provider)
    }
    
    public func newScriptRunner() throws -> ScriptRunner {
        return try ScriptRunner(self._context!, _nodeConfig!.provider)
    }
    
    public func newCallerScriptRunner() throws -> ScriptRunner {
        return try ScriptRunner(self._contextCaller!, _nodeConfig!.provider)
    }

    public func newBackup() throws -> Backup {
        return try Backup(self._context!, _nodeConfig!.targetHost)
    }
    
    public var appId: String {
        return self._appInstanceDid!.appId
    }
    
    public var callerDid: String {

        return self._callerDid!
    }

}
