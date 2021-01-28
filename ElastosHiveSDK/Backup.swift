/*
* Copyright (c) 2021 Elastos Foundation
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

public class Backup: NSObject{
    var authHelper: VaultAuthHelper
    private var vaultUrl: VaultURL

    init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
        self.vaultUrl = authHelper.vaultUrl
    }
    
    public func state() -> Promise<State> {
        return authHelper.checkValid().then { _ -> Promise<State> in
            return self.stateImp(0)
        }
    }
    
    private func stateImp(_ tryAgain: Int) -> Promise<State> {
        return Promise<State> { resolver in
            let url = vaultUrl.state()
            let response = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
                stateImp(1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            let type = json["hive_backup_state"].stringValue
            let stat = State(rawValue: type)
            resolver.fulfill(stat!)
        }
    }
    
    public func save(_ handler: BackupAuthenticationHandler) -> Promise<Bool> {
        return authHelper.checkValid().then { [self] _ -> Promise<String> in
            return handler.authorization(authHelper.serviceDid!)
        }.then { credential -> Promise<Bool> in
            return self.saveImp(credential, 0)
        }
    }
    
    private func saveImp(_ credential: String, _ tryAgain: Int) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let url = vaultUrl.save()
            let param = ["backup_credential": credential]
            let response = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
            }
            resolver.fulfill(true)
        }
    }
    
    public func restore(_ handler: BackupAuthenticationHandler) -> Promise<Bool> {
        return authHelper.checkValid().then { [self] _ -> Promise<String> in
            return handler.authorization(authHelper.serviceDid!)
        }.then { credential -> Promise<Bool> in
            return self.restoreImp(credential, 0)
        }
    }
    
    private func restoreImp(_ credential: String, _ tryAgain: Int) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let url = vaultUrl.restore()
            let param = ["backup_credential": credential]
            let response = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
            }
            resolver.fulfill(true)
        }
    }
    
    public func active() -> Promise<Bool> {
        return authHelper.checkValid().then { [self] _ -> Promise<Bool> in
            return activeImp(0)
        }
    }
    
    private func activeImp(_ tryAgain: Int) -> Promise<Bool> {
        return Promise<Bool> { resolver in
//            vaultUrl.resetVaultApi(baseUrl: "https://hive-testnet2.trinity-tech.io")
            let url = vaultUrl.activate()
            let param: [String: Any] = [: ]
            let response = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
                activeImp(1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }
}

