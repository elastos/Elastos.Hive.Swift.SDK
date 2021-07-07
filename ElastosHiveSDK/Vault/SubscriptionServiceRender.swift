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

public class SubscriptionServiceRender {
//    private var _serviceEndpoint: ServiceEndpoint
//    
//    public init(_ serviceEndpoint: ServiceEndpoint) {
//        self._serviceEndpoint = serviceEndpoint
//    }
//    
//    func subscribe() -> Promise<Void> {
//        return Promise<Any>.async().then{ _ -> Promise<Void> in
//            return Promise<Void> { resolver in
//                do {
//                    let url = self._serviceEndpoint.connectionManager.hiveApi.createVault()
//                    let header = try self._serviceEndpoint.connectionManager.headers()
//                    let response = try HiveAPi.request(url: url, method: .post, parameters: nil, headers: header).get(VaultCreateResponse.self)
//                    if response.existing == true {
//                        resolver.reject(HiveError.VaultAlreadyExistException("The vault already exists"))
//                    }
//                    resolver.fulfill(Void())
//                } catch {
//                    resolver.reject(error)
//                }
//            }
//        }
//    }
//    
//    func subscribeBackup() -> Promise<Void> {
//        return Promise<Any>.async().then{ _ -> Promise<Void> in
//            return Promise<Void> { resolver in
//                do {
//                    let url = self._serviceEndpoint.connectionManager.hiveApi.createBackupVault()
//                    let header = try self._serviceEndpoint.connectionManager.headers()
//                    let response = try HiveAPi.request(url: url, method: .post, parameters: nil, headers: header).get(VaultCreateResponse.self)
//                    if response.existing == true {
//                        resolver.reject(HiveError.VaultAlreadyExistException("The vault already exists"))
//                    }
//                    resolver.fulfill(Void())
//                } catch {
//                    resolver.reject(error)
//                }
//            }
//        }
//    }
//    
//    func unsubscribe() -> Promise<Void> {
//        return Promise<Any>.async().then{ _ -> Promise<Void> in
//            return Promise<Void> { resolver in
//                do {
//                    let url = self._serviceEndpoint.connectionManager.hiveApi.removeVault()
//                    let header = try self._serviceEndpoint.connectionManager.headers()
//                    _ = try HiveAPi.request(url: url, method: .post, parameters: nil, headers: header).get(HiveResponse.self)
//                    resolver.fulfill(Void())
//                } catch {
//                    resolver.reject(error)
//                }
//            }
//        }
//    }
//    
//    func activate() -> Promise<Void> {
//        return Promise<Any>.async().then{ _ -> Promise<Void> in
//            return Promise<Void> { resolver in
//                do {
//                    let url = self._serviceEndpoint.connectionManager.hiveApi.unfreeze()
//                    let header = try self._serviceEndpoint.connectionManager.headers()
//                    _ = try HiveAPi.request(url: url, method: .post, parameters: nil, headers: header).get(HiveResponse.self)
//                    resolver.fulfill(Void())
//                } catch {
//                    resolver.reject(error)
//                }
//            }
//        }
//    }
//    
//    func deactivate() -> Promise<Void> {
//        return Promise<Any>.async().then{ _ -> Promise<Void> in
//            return Promise<Void> { resolver in
//                do {
//                    let url = self._serviceEndpoint.connectionManager.hiveApi.freeze()
//                    let header = try self._serviceEndpoint.connectionManager.headers()
//                    _ = try HiveAPi.request(url: url, method: .post, parameters: nil, headers: header).get(HiveResponse.self)
//                    resolver.fulfill(Void())
//                } catch {
//                    resolver.reject(error)
//                }
//            }
//        }
//    }
//    
//    func getVaultInfo() -> Promise<VaultInfoResponse> {
//        return Promise<Any>.async().then{ _ -> Promise<VaultInfoResponse> in
//            return Promise<VaultInfoResponse> { resolver in
//                do {
//                    let url = self._serviceEndpoint.connectionManager.hiveApi.getVaultInfo()
//                    let header = try self._serviceEndpoint.connectionManager.headers()
//                    let response = try HiveAPi.request(url: url, method: .get, parameters: nil, headers: header).get(VaultInfoResponse.self)
//                    resolver.fulfill(response)
//                } catch {
//                    resolver.reject(error)
//                }
//            }
//        }
//    }
//    
//    func getBackupVaultInfo() -> Promise<VaultInfoResponse> {
//        return Promise<Any>.async().then{ _ -> Promise<VaultInfoResponse> in
//            return Promise<VaultInfoResponse> { resolver in
//                do {
//                    let url = self._serviceEndpoint.connectionManager.hiveApi.getBackupVaultInfo()
//                    let header = try self._serviceEndpoint.connectionManager.headers()
//                    let response = try HiveAPi.request(url: url, method: .post, parameters: nil, headers: header).get(VaultInfoResponse.self)
//                    resolver.fulfill(response)
//                } catch {
//                    resolver.reject(error)
//                }
//            }
//        }
//    }
}
