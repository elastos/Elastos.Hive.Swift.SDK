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
        self.authenticationDIDDocument = options.authenticationDIDDocument
        self.authentcationHandler = options.authenicator!
        self.localDataPath = options.localPath
    }

    public class func setupResolver() throws {
        try setupResolver(_reslover, _cacheDir)
    }

    public class func setupResolver(_ resolver: String, _ cacheDir: String) throws {
        guard resolver != "" else {
            throw HiveError.failure(des: "resolver is not nil.")
        }
        guard cacheDir != "" else {
            throw HiveError.failure(des: "cacheDir is not nil.")
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

    public static func createInstance(withOptions: HiveClientOptions) throws -> HiveClientHandle {
        guard resolverDidSetup else {
            throw HiveError.failure(des: "Setup did resolver first")
        }
        return HiveClientHandle(withOptions)
    }

    public func getVault(_ ownerDid: String) -> HivePromise<Vault> {
        return HivePromise<Vault> { resolver in
            var vaultProvider = ""
            _ = HiveClientHandle.getVaultProvider(ownerDid).done { [self] provider in
                vaultProvider = provider
                
                //vaultProvider = "http://192.168.1.6:5000" // TMP BPI

                var vault: Vault
                guard vaultProvider != "" else {
                    resolver.reject(HiveError.providerIsNil(des: "Please set provider first. provider is nil."))
                    return
                }
                let authHelper = VaultAuthHelper(ownerDid, vaultProvider, localDataPath, authenticationDIDDocument, authentcationHandler)
                vault = Vault(authHelper, vaultProvider, ownerDid)
                resolver.fulfill(vault)
            }
            .catch{ error in
                resolver.reject(error)
            }
        }
    }

    public class func getVaultProvider(_ ownerDid: String) -> HivePromise<String> {

        return HivePromise<String> { resolver in
            let globalQueue = DispatchQueue.global()
            globalQueue.async {
                var vaultProvider: String?
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

    public class func setVaultProvider(_ ownerDid: String, _ vaultAddress: String) {
        _providerCache[ownerDid] = vaultAddress
    }
}
