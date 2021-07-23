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
        try DIDBackend.initialize(DummyAdapter(_reslover))
        resolverDidSetup = true
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
                    let services = try doc?.selectServices(byType: "HiveVault")
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
    
    /// run script by hive url
    /// - Parameters:
    ///   - scriptUrl: hive://target_did@target_app_did/script_name?params={key=value}
    ///   - resultType: resultType
    /// - Returns:
    public func callScriptUrl<T>(_ scriptUrl: String, _ resultType: T.Type) -> Promise<T> {
        return parseHiveURL(scriptUrl).then { hiveinfo -> Promise<T> in
            return hiveinfo.callScript(resultType)
        }
    }
    
    /// Convenient method that first calls a script by url using callScriptURL(), and expects the
    /// JSON output to contain a file download information. If this is the case, the file download is
    /// starting and a file reader is returned.
    /// - Parameters:
    ///   - scriptUrl:
    ///   - resultType:
    /// - Returns:
    public func downloadFileByScriptUrl(_ scriptUrl: String) -> Promise<FileReader> {
        return parseHiveURL(scriptUrl).then { hiveinfo -> Promise<FileReader> in
            return hiveinfo.downloadFile()
        }
    }
    
    /// Parses a Hive standard url into a url info that can later be executed to get the result or the
    /// target url.
    ///
    /// For example, later calling a url such as ...
    ///      hive://userdid:appdid/getAvatar
    ///
    /// ... results in a call to the "getAvatar" script, previously registered by "userdid" on his vault,
    /// in the "appdid" scope. This is similar to calling:
    ///      hiveClient.getVault(userdid).getScripting().call("getAvatar");
    ///
    /// Usage example (assuming the url is a call to a getAvatar script that contains a FileDownload
    /// executable named "download"):
    /// - let hiveURLInfo = hiveclient.parseHiveURL(urlstring)
    /// - let scriptOutput = hiveURLInfo.callScript()
    /// - hiveURLInfo.getVault().getScripting().downloadFile(scriptOutput.items["download"].getTransferID())
    public func parseHiveURL(_ scriptUrl: String) -> Promise<HiveURLInfo> {
        return DispatchQueue.global().async(.promise) { [self] in
            return try HiveURLInfoImpl(self, context, authenticationAdapterImpl, scriptUrl)
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

public class HiveURLInfoImpl: HiveURLInfo {

    private let HIVE_URL_PREFIX = "hive://"
    private var targetDid: String
    private var appDid: String
    private var scriptName: String
    private var params: [String : Any] = [: ]
    private var _client: HiveClientHandle
    private var _context: ApplicationContext
    private var _authenticationAdapter: AuthenticationAdapter
    private var _vault: Vault!
    
    init(_ client: HiveClientHandle,_ context: ApplicationContext, _ authenticationAdapter: AuthenticationAdapter, _ scriptUrl: String) throws {
        if scriptUrl.prefix(7) != HIVE_URL_PREFIX {
            throw HiveError.invalidParameterError(des: "Invalid hive script url: no hive prefix.")
        }
        
        let parts = scriptUrl.suffix(scriptUrl.count - HIVE_URL_PREFIX.count).split(separator: "/")
        
        if (parts.count < 2) {
            throw HiveError.invalidParameterError(des: "Invalid hive script url: must contain at least one slash.")
        }

        let dids = parts[0].split(separator: "@")
        if (dids.count != 2) {
            throw HiveError.invalidParameterError(des: "Invalid hive script url: must contain two dids.")
        }
        let star = scriptUrl.count - (HIVE_URL_PREFIX.count + parts[0].count + 1)
        let values = scriptUrl.suffix(star).split(separator: "?")
        if (values.count != 2) {
            throw HiveError.invalidParameterError(des: "Invalid hive script url: must contain script name and params.")
        }
        targetDid = String(dids[0])
        appDid = String(dids[1])
        scriptName = String(values[0])
        let data = String(values[1].suffix(values[1].count - 7)).data(using: String.Encoding.utf8)
        do {
            params = try JSONSerialization.jsonObject(with: data!,
                            options: .mutableContainers) as! [String : Any]
        }
        catch {
            throw HiveError.IllegalArgument(des: "Invalid parameters format in hive script url.")
        }

        _client = client
        _context = context
        _authenticationAdapter = authenticationAdapter
    }
    
    public func callScript<T>(_ resultType: T.Type) -> Promise<T> {
        return getVault().then { [self] vault -> Promise<T> in
            return vault.scripting.callScript(scriptName, params, appDid, resultType)
        }
    }
    
    public func downloadFile() -> Promise<FileReader> {
        return getVault().then { [self] vault -> Promise<JSON> in
            _vault = vault
            return vault.scripting.callScript(scriptName, self.params, appDid, JSON.self)
        }.then { [self] result -> Promise<FileReader> in
            var transaction_id = ""
            for (_, value) in result {
                if value["transaction_id"].stringValue != "" {
                    transaction_id = value["transaction_id"].stringValue
                    break
                }
            }
            return _vault.scripting.downloadFile(transaction_id)
        }
    }

    public func getVault() -> Promise<Vault> {
//        return _client.getVault(targetDid, "https://hive2.trinity-tech.io")
        return _client.getVault(targetDid, nil)
    }
}
