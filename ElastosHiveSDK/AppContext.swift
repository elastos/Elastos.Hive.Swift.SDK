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
import ElastosDIDSDK

/// The application context would contain the resources list below:
/// - The reference of application context provider.
/// - The user did which uses this application.
/// Normally, there are only one application context for one application.
public class AppContext {
    
    private static var resolverHasSetup: Bool = false
    private var _contextProvider: AppContextProvider
    private var _userDid: String
    
    public init(_ provider: AppContextProvider, _ userDid: String) {
        _userDid = userDid
        _contextProvider = provider
    }
    
    /// Get the provider of the application context.
    /// - returns: The provider of the application context.
    public var appContextProvider: AppContextProvider {
        return _contextProvider
    }
    
    /// Get the user DID.
    /// - returns: The user DID.
    public var userDid: String {
        return _userDid
    }
    
    /// Setup the resolver for the DID verification.
    ///
    /// - parameters:
    ///   - resolver: The URL of the resolver.
    ///   - cacheDir: The local directory for DID cache.
    public static func setupResover(_ resolver: String, _ cacheDir: String) throws {
        guard resolverHasSetup == false else {
            throw HiveError.DIDResoverAlreadySetupException(nil)
        }
        
        do {
            try DIDBackend.initialize(DefaultDIDAdapter(resolver))
            resolverHasSetup = true
        } catch {
            throw error //TODO: need to throw specific error.
        }
    }
    
    /// Create the application context.
    ///
    /// - parameters:
    ///   - provider: The provider of the application context.
    ///   - userDid: The user DID.
    /// - returns: The application context.
    public static func build(_ provider: AppContextProvider, _ userDid: String) throws -> AppContext {
        guard provider.getLocalDataDir() != nil else {
            throw HiveError.BadContextProviderException("Missing method to acquire data location")
        }
        
        guard provider.getAppInstanceDocument() != nil else {
            throw HiveError.BadContextProviderException("Missing method to acquire App instance DID document")
        }
        
        guard self.resolverHasSetup else{
            throw HiveError.DIDResolverNotSetupException(nil)
        }

        return AppContext(provider, userDid)
    }
    
    /// Get the URL address of the provider throw the document of the user DID. The will access the property of the document of the user DID.
    ///
    /// - parameters:
    ///   - targetDid: The user DID.
    /// - returns: The URL address of the provider.
    public static func getProviderAddress(_ targetDid: String) -> Promise<String> {
        return getProviderAddress(targetDid, nil)
    }
    
    /// Get the URL address of the provider by the user DID. The will access the property of the user DID.
    ///
    /// - parameters:
    ///   - targetDid: The user DID.
    ///   - preferredProviderAddress: The preferred URL address of the provider.
    /// - returns: The URL address of the provider.    
    private static func getProviderAddress(_ targetDid: String, _ preferredProviderAddress: String?) -> Promise<String> {
        return DispatchQueue.global().async(.promise){
            if preferredProviderAddress != nil {
                return preferredProviderAddress!
            }
            
            let did = try DID(targetDid)
            let doc = try did.resolve()
            guard doc != nil else {
                throw HiveError.DIDNotPublishedException("The DID \(targetDid) has not published onto sideChain")
            }
            let services = try doc!.selectServices(byType: "HiveVault")
            if services.count == 0 {
                throw HiveError.ProviderNotSetException("No 'HiveVault' services declared on DID document \(targetDid)")
            }
            return services[0].endpoint
        }
    }
}
