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

private var _vaultCache: [DID: Vault]?
let HiveVaultQueue = DispatchQueue(label: "org.elastos.hivesdk.queue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .workItem)
@objc(HiveClient)
public class HiveClientHandle: NSObject {
    private static var _reslover: String = "http://api.elastos.io:20606" // Default
    private static var _cacheDir: String = "\(NSHomeDirectory())/Library/Caches/didCache" // Default
    private static var resolverDidSetup: Bool = false // Default

    private var authenticationAdapterImpl: AuthenticationAdapterImpl
    private var context: ApplicationContext

    init(_ context: ApplicationContext) {
        PromiseKit.conf.Q = (map: HiveVaultQueue, return: HiveVaultQueue)
        self.authenticationAdapterImpl = AuthenticationAdapterImpl(context)
        self.context = context
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
            throw HiveError.IllegalArgument(des: "resolver should not be nil.")
        }
        guard cacheDir != "" else {
            throw HiveError.IllegalArgument(des: "cacheDir should not be nil.")
        }

        guard !HiveClientHandle.resolverDidSetup else {
//            throw HiveError.failure(des: "Resolver already setuped")
            return
        }
        _reslover = resolver
        _cacheDir = cacheDir
        try DIDBackend.initializeInstance(_reslover, _cacheDir)
        resolverDidSetup = true
        try ResolverCache.reset() // 删除了整个路径 ！！！！
    }

    /// Create a Client instance
    /// - Parameter withOptions: authentication options
    /// - Throws: throw an error, when an error occurs
    /// - Returns: client instance
    public static func createInstance(withContext: ApplicationContext) throws -> HiveClientHandle {
        guard resolverDidSetup else {
            throw HiveError.IllegalArgument(des: "Setup did resolver first")
        }
        return HiveClientHandle(withContext)
    }

    /// Create Vault for user with specified DID.
    /// Try to create a vault on target provider address with following steps:
    ///  - Get the target provider address
    ///  - Check whether the vault is already existed on target provider, otherwise
    ///  - Create a new vault on target provider with free pricing plan.
    /// - Parameters:
    ///   - ownerDid: The owner did that want to create a vault
    ///   - providerAddress: The preferred provider address to use
    /// - Returns: vault instance
    public func createVault(_ ownerDid: String, _ preferredProviderAddress: String?) -> Promise<Vault>{
        return getVaultProvider(ownerDid, preferredProviderAddress).then{ provider -> Promise<Vault?> in
            let authHelper = VaultAuthHelper(self.context,
                                             ownerDid,
                                             provider,
                                             self.authenticationAdapterImpl)
            let vault = Vault(authHelper, provider, ownerDid)
            return vault.checkVaultExist()
        }.then{ vault -> Promise<Vault> in
            guard vault != nil else {
                throw HiveError.vaultAlreadyExistException(des: "Vault already existed.")
            }
            return vault!.requestToCreateVault()
        }
    }

    /// get Vault instance with specified DID.
    /// Try to get a vault on target provider address with following steps:
    ///   - Get the target provider address
    ///   - Create a new vaule of local instance..
    /// - Parameters:
    ///   - ownerDid: The owner did related to target vault
    ///   - preferredProviderAddress: The preferred target provider address
    /// - Returns: vault instance.
    public func getVault(_ ownerDid: String, _ preferredProviderAddress: String?) -> Promise<Vault> {
        return Promise<Vault> { resolver in
            _ = getVaultProvider(ownerDid, preferredProviderAddress).done{ provider in
                let authHelper = VaultAuthHelper(self.context,
                                                ownerDid,
                                                provider,
                                                self.authenticationAdapterImpl)
                resolver.fulfill(Vault(authHelper, provider, ownerDid))
            }.catch{ error in
                resolver.reject(error)
            }
        }
    }

    /// Try to acquire provider address for the specific user DID with rules with sequence orders:
    ///  - Use 'preferredProviderAddress' first when it's being with real value; Otherwise
    ///  - Resolve DID document according to the ownerDid from DID sidechain,
    ///    and find if there are more than one "HiveVault" services, then would
    ///    choose the first one service point as target provider address. Otherwise
    ///  - It means no service endpoints declared on this DID Document, then would throw the
    ///    corresponding exception.
    ///  - Parameters:
    ///  - ownerDid: The owner did that want be set provider address
    ///  - providerAddress: The preferred provider address to use
    ///  - Returns: The provider address
    public func getVaultProvider(_ ownerDid: String, _ preferredProviderAddress: String?) -> Promise<String> {
        return Promise<String> { resolver in
            DispatchQueue.global().async {
                
                /// Choose 'preferredProviderAddress' as target provider address if it's with value
                if preferredProviderAddress != nil {
                    resolver.fulfill(preferredProviderAddress!)
                    return
                }
                do {
                    let did = try DID(ownerDid)
                    let doc = try did.resolve()
                    guard let _ = doc else {
                        resolver.reject(HiveError.providerNotSet(des: "The DID document \(ownerDid) has not published."))
                        return
                    }
                    let services = doc?.selectServices(byType: "HiveVault")
                    if services == nil || services!.count == 0 {
                        resolver.reject(HiveError.providerNotSet(des: "No 'HiveVault' services declared on DID document \(ownerDid)"))
                        return
                    }
                    resolver.fulfill(services![0].endpoint)
                }
                catch {
                    resolver.reject(error)
                }
            }
        }
    }
}

public class AuthenticationAdapterImpl: AuthenticationAdapter {
    private var context: ApplicationContext
    init(_ context: ApplicationContext) {
        self.context = context
    }
    
    public func authenticate(_ context: ApplicationContext, _ jwtToken: String) -> Promise<String> {
        return context.getAuthorization(jwtToken)
    }
}
