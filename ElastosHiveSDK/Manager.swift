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

public class Manager: NSObject{
    private var providerAddress: String
    private var ownerDid: String
    private var authHelper: VaultAuthHelper
    private var serviceManager: ServiceManager
    
    init(_ authHelper: VaultAuthHelper, _ providerAddress: String, _ ownerDid: String) {
        self.providerAddress = providerAddress
        self.authHelper = authHelper
        self.ownerDid = ownerDid
        self.serviceManager = ServiceManager(authHelper)
    }
    
    public func createVault() -> Promise<Vault> {
        return Promise<Vault> { resolver in
            self.serviceManager.createVault().done { success in
                resolver.fulfill(Vault(self.authHelper, self.providerAddress, self.ownerDid))
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    public func checkVaultExist() -> Promise<Bool> {
        return Promise<Bool> { resolver in
            self.serviceManager.vaultServiceInfo().done { success in
                resolver.fulfill(true)
            }.catch { error in
                let e = error as! HiveError
                switch e {
                case .vaultNotFound(_): do {
                    resolver.fulfill(false)
                    return
                }
                default:
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func createBackup() -> Promise<Bool> {
        return Promise<Bool> { resolver in
            self.serviceManager.createBackupVault().done { success in
                resolver.fulfill(true)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    public func checkBackupVaultExist() -> Promise<Bool> {
        return Promise<Bool> { resolver in
            self.serviceManager.backupServiceInfo().done { success in
                resolver.fulfill(true)
            }.catch { error in
                let e = error as! HiveError
                switch e {
                case .vaultNotFound(_): do {
                    resolver.fulfill(false)
                    return
                }
                default:
                    resolver.reject(error)
                }
            }
        }
    }
}
