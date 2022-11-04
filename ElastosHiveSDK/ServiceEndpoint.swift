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
import AwaitKit

/**
 * The service end-point represents the service provides some API functions. It supports:
 *
 * Access token management.
 * Local cache for the access token.
 * The service DID of the hive node.
 * The provider address.
 *
 * The service end-point is just like the map of the hive node. The application can communicate
 *         with the hive node APIs by its sub-class.
 */
public class ServiceEndpoint: NodeRPCConnection {
    public var connectionManager: ConnectionManager?
    
    private var _context: AppContext
    private var _providerAddress: String

    private var _appDid: String?
    private var _appInstanceDid: String?
    private var _serviceInstanceDid: String?

    private var _accessToken: AccessToken?
    private var _dataStorage: DataStorage?
    
    public init(_ context: AppContext) throws {
        _providerAddress = try `await`(context.getProviderAddress())
        _context = context
        super.init()
        try create(context, providerAddress)
    }
    
    /// Create by the application context, and the address of the provider.
    ///
    /// - parameters:
    ///   - context: The application context.
    ///   - providerAddress: The address of the provider.
    public init(_ context: AppContext, _ providerAddress: String) throws {
        _providerAddress = providerAddress
        _context = context
        super.init()
        try create(context, providerAddress)
    }

    /// Create by the application context, and the address of the provider.
    ///
    /// - parameters:
    ///   - context: The application context.
    ///   - providerAddress: The address of the provider.
    private func create(_ context: AppContext, _ providerAddress: String) throws {
        
        self.connectionManager = ConnectionManager(_providerAddress)
        
        let dataDir = _context.appContextProvider.getLocalDataDir()
        _dataStorage = try FileStorage(dataDir!, _context.userDid)
        _accessToken = AccessToken(self, _dataStorage)
        var err: Error?
        _accessToken!.flush = { (value) in
            do {
                let claims = try JwtParserBuilder().setAllwedClockSkewSeconds(300).build().parseClaimsJwt(value).claims
                let props = try claims.getAsJson(key: "props")
                let dic = props.getDictionaryFromJSONString()
                let appDid = (dic["appDid"] != nil) ? dic["appDid"] as! String : ""
                self.flushDids(claims.getAudience()!, appDid, claims.getIssuer()!)
            } catch {
                err = error
                print(error)
            }
        }
        guard err == nil else {
            throw err!
        }
        self.connectionManager?.accessToken = _accessToken;
    }
    
    /// Get the application context.
    ///
    /// - returns: The application context.
    public var appContext: AppContext {
        return _context
    }

    /// Get the end-point address of this service End-point.
    ///
    /// - returns: provider address
    public var providerAddress: String {
        return _providerAddress
    }

    /// Get the user DID string of this serviceEndpoint.
    ///
    /// - returns: user did
    public var userDid: String? {
        return _context.userDid
    }
    
    /// Get the application DID in the current calling context.
    ///
    /// - returns: application did
    public var appDid: String? {
        return _appDid
    }
    
    /// Get the application instance DID in the current calling context;
    ///
    /// - returns: application instance did
    public var appInstanceDid: String? {
        return _appInstanceDid
    }
    
    /// Get the remote node service application DID.
    ///
    /// - returns: node service did
    public var serviceDid: String? {
        try!{
            throw HiveError.NotImplementedException(nil)
        }()
        return nil
    }
    
    /// Get the remote node service instance DID where is serving the storage service.
    ///
    /// - returns: node service instance did
    public var serviceInstanceDid: String? {
        return _serviceInstanceDid
    }

    
    private func flushDids(_ appInstanceDId: String, _ appDid: String, _ serviceInstanceDid: String) {
        _appInstanceDid = appInstanceDId
        _serviceInstanceDid = serviceInstanceDid
        self._appDid = appDid
    }
    
    /// Get the instance of the data storage.
    ///
    /// - returns: The instance of the data storage.
    public func getStorage() -> DataStorage {
        return _dataStorage!
    }
    
    /// Refresh the access token. This will do remote refresh if not exist.
    public func refreshAccessToken() throws {
        try _ = _accessToken?.fetch()
    }
    
    public func getAccessToken() -> AccessToken {
        return _accessToken!
    }
    
    /// Get the version of the hive node.
    ///
    /// - returns: The version of the hive node.
    public func getNodeVersion() -> Promise<NodeVersion> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try AboutController(self).getNodeVersion()
        }
    }
    
    /// Get the last commit ID of the hive node.
    ///
    /// - returns: The last commit ID.
    public func getLatestCommitId() -> Promise<String?> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try AboutController(self).getCommitId()
        }
    }
    
    
    /// Get the information of the hive node.
    /// - Returns: The information.
    public func getNodeInfo() -> Promise<NodeInfo> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try AboutController(self).getNodeInfo()
        }
    }
}
