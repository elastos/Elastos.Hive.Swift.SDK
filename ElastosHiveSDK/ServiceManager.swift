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

public class ServiceManager: NSObject{
    private var authHelper: VaultAuthHelper
    private var vaultUrl: VaultURL
    
    init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
        self.vaultUrl = authHelper.vaultUrl
    }
    
    public func createVault() -> Promise<Bool> {
        return authHelper.checkValid().then { _ -> Promise<Bool> in
            return self.createVaultImp(0)
        }
    }
    
    private func createVaultImp(_ tryAgain: Int) -> Promise<Bool> {
        return Promise<Bool> { resolver in
//            authHelper.vaultUrl.resetVaultApi(baseUrl: "https://hive-testnet2.trinity-tech.io")
            let url = vaultUrl.createVault()
            let response = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                createVaultImp(1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }
    
    public func removeVault() -> Promise<Bool> {
        return authHelper.checkValid().then { _ -> Promise<Bool> in
            return self.removeVaultImp(0)
        }
    }
    
    private func removeVaultImp(_ tryAgain: Int) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let url = vaultUrl.removeVault()
            let response = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                removeVaultImp(1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }
    
    public func freezeVault() -> Promise<Bool> {
        return authHelper.checkValid().then { _ -> Promise<Bool> in
            return self.freezeVaultImp(0)
        }
    }
    
    private func freezeVaultImp(_ tryAgain: Int) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let url = vaultUrl.freezeVault()
            let response = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                freezeVaultImp(1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }
    
    public func unfreezeVault() -> Promise<Bool> {
        return authHelper.checkValid().then { _ -> Promise<Bool> in
            return self.unfreezeVaultImp(0)
        }
    }
    
    private func unfreezeVaultImp(_ tryAgain: Int) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let url = vaultUrl.unfreezeVault()
            let response = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                unfreezeVaultImp(1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }
    
    public func vaultServiceInfo() -> Promise<UsingPlan> {
        return authHelper.checkValid().then { _ -> Promise<UsingPlan> in
            return self.vaultServiceInfoImp(0)
        }
    }
    
    private func vaultServiceInfoImp(_ tryAgain: Int) -> Promise<UsingPlan> {
        return Promise<UsingPlan> { resolver in
            let url = vaultUrl.vaultServiceInfo()
            let response = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let errorCode = json["_error"]["code"].intValue
            guard errorCode != 404 else {
                throw HiveError.vaultNotFound(des: "vault not found.")
            }
            if json.isEmpty || json["vault_service_info"].isEmpty {
                throw HiveError.vaultNotFound(des: "vault not found.")
            }
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
                vaultServiceInfoImp(1).done { plan in
                    resolver.fulfill(plan)
                }.catch { (error) in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(UsingPlan.deserialize(json["vault_service_info"]))
        }
    }
    
    public func createBackup() -> Promise<Bool> {
        return authHelper.checkValid().then { _ -> Promise<Bool> in
            return self.createBackupVaultImp(0)
        }
    }
    
    private func createBackupVaultImp(_ tryAgain: Int) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let url = vaultUrl.createBackupVault()
            let response = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                createBackupVaultImp(1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }
    
    public func backupServiceInfo() -> Promise<BackupUsingPlan> {
        return authHelper.checkValid().then { _ -> Promise<BackupUsingPlan> in
            return self.backupServiceInfoImp(0)
        }
    }
    
    private func backupServiceInfoImp(_ tryAgain: Int) -> Promise<BackupUsingPlan> {
        return Promise<BackupUsingPlan> { resolver in
            let url = vaultUrl.backupVaultInfo()
            let response = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let errorCode = json["_error"]["code"].intValue
            guard errorCode != 404 else {
                throw HiveError.vaultNotFound(des: "vault not found.")
            }
            if json.isEmpty || json["vault_service_info"].isEmpty {
                throw HiveError.vaultNotFound(des: "vault not found.")
            }
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
                backupServiceInfoImp(1).done { plan in
                    resolver.fulfill(plan)
                }.catch { (error) in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(BackupUsingPlan.deserialize(json["vault_service_info"]))
        }
    }
}
