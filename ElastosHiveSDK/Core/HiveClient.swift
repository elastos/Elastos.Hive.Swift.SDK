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

public typealias HivePromise = Promise
private var _providerCache: [String: String] = [: ]
private var _vaultCache: [DID: Vault]?
let HiveVaultQueue = DispatchQueue(label: "org.elastos.hivesdk.queue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .workItem)
@objc(HiveClient)
public class HiveClientHandle: NSObject {
    private static var _reslover: String = "http://api.elastos.io:20606" // Default
    private static var _cacheDir: String = "\(NSHomeDirectory())/Library/Caches/didCache" // Default
    private static var resolverDidSetup: Bool = false // Default

    private var authenticationDIDDocument: DIDDocument
    private var authentcationHandler: Authenticator
    private var localDataPath: String
    private var cachedProviders: [String: Any] = [: ]

    init(_ options: HiveClientOptions) {
        PromiseKit.conf.Q = (map: HiveVaultQueue, return: HiveVaultQueue)
        self.authenticationDIDDocument = options.authenticationDIDDocument
        self.authentcationHandler = options.authenicator!
        self.localDataPath = options.localPath
    }

    /// Constructor without parameters
    /// resolver url and cache path use default value:
    /// http://api.elastos.io:20606
    /// \(NSHomeDirectory())/Library/Caches/didCache
    /// - Throws: throw an error, when an error occurs
    public class func setupResolver() throws {
        try setupResolver(_reslover, _cacheDir)
    }

    /// Recommendation for cache dir:
    /// - Parameters:
    ///   - resolver: resolver the DIDResolver object
    ///   - cacheDir: cacheDir the cache path name
    /// - Throws: throw an error, when an error occurs
    public class func setupResolver(_ resolver: String, _ cacheDir: String) throws {
        guard resolver != "" else {
            throw HiveError.IllegalArgument(des: "resolver is not nil.")
        }
        guard cacheDir != "" else {
            throw HiveError.IllegalArgument(des: "cacheDir is not nil.")
        }

        guard !HiveClientHandle.resolverDidSetup else {
//            throw HiveError.failue(des: "Resolver already setuped")
            return
        }
        _reslover = resolver
        _cacheDir = cacheDir
        try DIDBackend.initializeInstance(_reslover, _cacheDir)
        resolverDidSetup = true
        //ResolverCache.reset() // 删除了整个路径 ！！！！
    }

    /// Create a Client instance
    /// - Parameter withOptions: authentication options
    /// - Throws: throw an error, when an error occurs
    /// - Returns: client instance
    public static func createInstance(withOptions: HiveClientOptions) throws -> HiveClientHandle {
        guard resolverDidSetup else {
            throw HiveError.IllegalArgument(des: "Setup did resolver first")
        }
        return HiveClientHandle(withOptions)
    }

    private func newVault(_ provider: String, _ ownerDid: String) -> Vault {
        let authHelper = VaultAuthHelper(ownerDid, provider, localDataPath, authenticationDIDDocument, authentcationHandler)
        return Vault(authHelper, provider, ownerDid)
    }
    
    /// Create Vault
    /// - Parameters:
    ///   - ownerDid: ownerDid
    ///   - providerAddress: provider address
    /// - Returns: vault instance
    public func createVault(_ ownerDid: String, _ providerAddress: String?) -> HivePromise<Vault>{
        return HivePromise<Vault> { resolver in
            var vault: Vault?
            _ = getVaultProvider(ownerDid, providerAddress).then{ provider -> HivePromise<Bool> in
                vault = self.newVault(provider, ownerDid)
                return vault!.useTrial()
            }.done{ success in
                resolver.fulfill(vault!)
            }.catch{ error in
                resolver.reject(error)
            }
        }
    }

    /// Get Vault
    /// - Parameters:
    ///   - ownerDid: vault owner did
    ///   - providerAddress: provider address
    /// - Returns: vault instance
    public func getVault(_ ownerDid: String, _ providerAddress: String?) -> HivePromise<Vault> {
        return HivePromise<Vault> { resolver in
            var vault: Vault?
            _ = getVaultProvider(ownerDid, providerAddress).then{ [self] provider -> HivePromise<UsingPlan> in
                vault = newVault(provider, ownerDid)
                return vault!.getUsingPricePlan()
            }.done{ plan in
                resolver.fulfill(vault!)
            }.catch{ error in
                resolver.reject(error)
            }
        }
    }

    /// Tries to find a vault address in the public DID document of the given user's DID.
    /// - Parameters:
    ///   - ownerDid: ownerDid the owner did for the vault
    ///   - providerAddress: the vault address in String
    /// - Returns: the vault address in String
    public func getVaultProvider(_ ownerDid: String, _ providerAddress: String?) -> HivePromise<String> {

        return HivePromise<String> { resolver in
            DispatchQueue.global().async {
                var vaultProvider: String?
                
                if let _ = providerAddress {
                    resolver.fulfill(providerAddress!)
                    return
                }
                do {
                    let did = try DID(ownerDid)
                    let doc = try did.resolve()
                    let services = doc?.selectServices(byType: "HiveVault")
                    if services != nil && services!.count > 0 {
                        vaultProvider = services![0].endpoint
                        _providerCache[ownerDid] = vaultProvider
                    }
                    else {
                        vaultProvider = _providerCache[ownerDid]
                    }
                    if vaultProvider == nil {
                        vaultProvider = ""
                    }
                    resolver.fulfill(vaultProvider!)
                }
                catch {
                    resolver.reject(error)
                }
            }
        }
    }
}
