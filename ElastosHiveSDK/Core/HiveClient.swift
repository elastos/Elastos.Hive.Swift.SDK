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

@objc(HiveClient)
public class HiveClientHandle: NSObject {
    private var _opts: HiveClientOptions
    private var _vaultCache: [DID: Vault]?
    private var _providerCache: [String: String] = [: ]
    public init(_ options: HiveClientOptions) {
        self._opts = options
    }

//    public func connect() throws {}
//    public func connectAsync() -> HivePromise<Void> {
//        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
//    }
//
//    public func disconnect() {}
//    public func isConnected() -> Bool {
//        return false
//    }
//
//    public func asFiles() -> FilesProtocol? {
//        return nil
//    }
//
//    public func asDatabase() -> DatabaseProtocol? {
//        return nil
//    }
//
//    public func asKeyValues() -> KeyValuesProtocol? {
//        return nil
//    }
//
//    public func asScripting() -> ScriptingProtocol? {
//        return nil
//    }

    public static func createInstance(withOptions: HiveClientOptions) throws -> HiveClientHandle {
        let client = withOptions.buildClient()
        guard client != nil else {
            throw HiveError.failue(des: "Not implemented")
        }

        return client!
    }

    public func getVault(_ ownerDid: String) -> HivePromise<Vault> {
        return HivePromise<Vault> { resolver in
            var vaultProvider = ""
            _ = getVaultProvider(ownerDid).get { result in
                vaultProvider = result

                var vault: Vault
                guard vaultProvider != "" else {
                    resolver.reject("TODO" as! Error)
                    return
                }
                let authHelper = VaultAuthHelper(vaultProvider, self._opts.localPath, self._opts.authenticationDIDDocument, self._opts.authenicator)
                vault = Vault(authHelper, vaultProvider, ownerDid)
                resolver.fulfill(vault)
            }
            .catch{ error in
                resolver.reject(error)
            }
        }
    }

    public func getVaultProvider(_ ownerDid: String) -> HivePromise<String> {

        return HivePromise<String> { resolver in
            var vaultProvider: String?
            do {
                if _opts.didResolverUrl == nil {
                   try DIDBackend.initializeInstance(MAIN_NET_RESOLVER, _opts.localPath)
                }
                else {
                    try DIDBackend.initializeInstance(_opts.didResolverUrl!, _opts.localPath)
                }
                try ResolverCache.reset()
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
                // TODO: 返回值vaultProvider是否可以为nil ！！！！！！！！
                resolver.fulfill(vaultProvider!)
            }
            catch {
                resolver.reject(error)
            }

        }
    }
}
