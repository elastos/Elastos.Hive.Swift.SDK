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

public class AppContext {
    private static var resolverHasSetup: Bool = false
    private var contextProvider: AppContextProvider?
    private var _userDid: String?
    private var _providerAddress: String?
    private var _connectionManager: ConnectionManager?

    public convenience init(_ provider: AppContextProvider?, _ userDid: String?) {
        self.init(provider!, userDid, nil)
    }
    
    public init(_ provider: AppContextProvider?, _ userDid: String?, _ providerAddress: String?) {
        self.contextProvider = provider!
        self._userDid = userDid
        self._providerAddress = providerAddress
        self._connectionManager = try! ConnectionManager(self, "https://hive-testnet1.trinity-tech.io", "/api/v1")
    }
    
    public static func setupResover(_ resolver: String, _ cacheDir: String) throws {

        guard resolverHasSetup == false else {
            throw HiveError.vaultAlreadyExistException(des: "Resolver already setup before")
        }
        
        try DIDBackend.initializeInstance(resolver, cacheDir)
        try ResolverCache.reset()
        resolverHasSetup = true
    }
    
    public var appContextProvider: AppContextProvider {
        return self.contextProvider!
    }
    
    public var userDid: String? {
        return self._userDid
    }
    
    public var providerAddress: String? {
        return self._providerAddress
    }

    public var connectionManager: ConnectionManager {
        return self._connectionManager!
    }
    
//    public static func build(_ provider: AppContextProvider) throws -> AppContext {
//        guard provider.getLocalDataDir() != nil else {
//            throw HiveError.IllegalArgument(des: "Missing method to acquire data location in AppContext provider")
//        }
//        
//        guard provider.getAppInstanceDocument() != nil else {
//            throw HiveError.IllegalArgument(des: "Missing method to acquire App instance DID document in AppContext provider")
//        }
//
//        return AppContext(provider, nil, nil)
//    }
    
    public static func build(_ provider: AppContextProvider, _ userDid: String, _ providerAddress: String) throws -> AppContext {
        guard provider.getLocalDataDir() != nil else {
            throw HiveError.IllegalArgument(des: "Missing method to acquire data location in AppContext provider")
        }
        
        guard provider.getAppInstanceDocument() != nil else {
            throw HiveError.IllegalArgument(des: "Missing method to acquire App instance DID document in AppContext provider")
        }

        return AppContext(provider, userDid, providerAddress)
    }

    public func getProviderAddress(_ targetDid: String) -> Promise<String> {
        return getProviderAddress(targetDid, nil)
    }
    
    public func getProviderAddress(_ targetDid: String, _ preferredProviderAddress: String?) -> Promise<String> {
        return Promise<Any>.async().then { _ -> Promise<String> in
            return Promise<String> { resolver in
                if preferredProviderAddress != nil {
                    resolver.fulfill(preferredProviderAddress!)
                    return
                }
                do {
                    let did = try DID(targetDid)
                    let doc = try did.resolve()
                    guard doc != nil else {
                        resolver.reject(HiveError.providerNotFound(des: "The DID \(targetDid) has not published onto sideChain"))
                        return
                    }
                    let services = doc?.selectServices(byType: "HiveVault")
                    if services == nil || services!.count == 0 {
                        resolver.reject(HiveError.providerNotSet(des: "No 'HiveVault' services declared on DID document \(targetDid)"))
                        return
                    }
                    resolver.fulfill(services![0].endpoint)
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func getVault(_ ownerDid: String, _ preferredProviderAddress: String) -> Promise<Vault> {
        return Promise<Any>.async().then { [self] _ -> Promise<String> in
            return getProviderAddress(ownerDid, preferredProviderAddress)
        }.then { (providerAddress) -> Promise<Vault> in
            self._providerAddress = providerAddress
            return Promise<Vault> { resolver in
                resolver.fulfill(Vault(self, ownerDid, providerAddress))
            }
        }
    }
}
