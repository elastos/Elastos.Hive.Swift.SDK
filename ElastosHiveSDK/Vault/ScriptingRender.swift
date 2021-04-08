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

public class ScriptingServiceRender: HiveVaultRender, ScriptingProtocol {
    let scriptRunner: ScriptRunner
    
    override init(_ vault: Vault) {
        self.scriptRunner = ScriptRunner(vault.appContext, vault.providerAddress, vault.userDid, vault.ownerDid, vault.appDid)
        super.init(vault)
    }
    
    public func registerScript(_ name: String, _ condition: Condition?, _ executable: Executable, _ allowAnonymousUser: Bool, _ allowAnonymousApp:  Bool) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let params = RegisterScriptRequestParams()
            params.name = name
            params.allowAnonymousUser = allowAnonymousUser
            params.allowAnonymousApp = allowAnonymousApp
            if condition != nil {
                params.condition = condition!
            }
            params.executable = executable
            print(params.toJSON())
            let url = self.connectionManager.hiveApi.registerScript()
            let header = try self.connectionManager.headers()
            _ = try HiveAPi.request(url: url, method: .post, parameters: params.toJSON(), headers: header).get(RegisterScriptResponse.self)
            resolver.fulfill(true)
        }
    }
    
    public func callScript<T>(_ name: String, _ params: [String : Any]?, _ appDid: String?, _ resultType: T.Type) -> Promise<T> {
        return Promise<Any>.async().then{ [self] _ -> Promise<T> in
            return scriptRunner.callScript(name, params, appDid, resultType)
        }
    }
    
    public func callScriptUrl<T>(_ name: String, _ params: String?, _ appDid: String, _ resultType: T.Type) -> Promise<T> {
        return Promise<Any>.async().then{ [self] _ -> Promise<T> in
            return scriptRunner.callScriptUrl(name, params, appDid, resultType)
        }
    }
    
    public func uploadFile(_ transactionId: String) -> Promise<FileWriter> {
        return Promise<Any>.async().then{ [self] _ -> Promise<FileWriter> in
            return scriptRunner.uploadFile(transactionId)
        }
    }
    
    public func downloadFile(_ transactionId: String) -> Promise<FileReader> {
        return Promise<Any>.async().then{ [self] _ -> Promise<FileReader> in
            return scriptRunner.downloadFile(transactionId)
        }
    }
}
