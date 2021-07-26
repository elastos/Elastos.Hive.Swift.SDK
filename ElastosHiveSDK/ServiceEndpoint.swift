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

public class ServiceEndpoint: NodeRPCConnection {
    public var connectionManager: ConnectionManager?
    
    private var _context: AppContext
    private var _providerAddress: String

    private var _appDid: String?
    private var _appInstanceDid: String?
    private var _serviceInstanceDid: String?

    private var _accessToken: AccessToken?
    private var _dataStorage: DataStorage?
    
    public init(_ context: AppContext, _ providerAddress: String) {
        _context = context
        _providerAddress = providerAddress
        super.init()
        self.connectionManager = ConnectionManager(_providerAddress)
        
        var dataDir = _context.appContextProvider.getLocalDataDir()
        if String((dataDir?.last)!) != "\\" {
            dataDir = dataDir! + "\\"
        }
        
        _dataStorage = FileStorage(dataDir!, _context.userDid)
        _accessToken = AccessToken(self, _dataStorage)
        _accessToken!.flush = { (value) in
            do {
                let claims = try JwtParserBuilder().build().parseClaimsJwt(value).claims
                self.flushDids(claims.getAudience()!, claims.getIssuer()!)
            } catch {
                print(error)
            }
            
        }
        self.connectionManager?.accessToken = _accessToken;
    }
    
    public var appContext: AppContext {
        return _context
    }

    /**
     * Get the end-point address of this service End-point.
     *
     * @return provider address
     */
    public var providerAddress: String {
        return _providerAddress
    }
    
    /**
     * Get the user DID string of this serviceEndpoint.
     *
     * @return user did
     */
    public var userDid: String? {
        return _context.userDid
    }
    
    /**
     * Get the application DID in the current calling context.
     *
     * @return application did
     */
    public var appDid: String? {
        return _appDid
    }
    
    /**
     * Get the application instance DID in the current calling context;
     *
     * @return application instance did
     */
    public var appInstanceDid: String? {
        return _appInstanceDid
    }
    
    /**
     * Get the remote node service application DID.
     *
     * @return node service did
     */
    public var serviceDid: String? {
        try!{
            throw HiveError.NotImplementedException(nil)
        }()
        return nil
    }
    
    /**
     * Get the remote node service instance DID where is serving the storage service.
     *
     * @return node service instance did
     */
    public var serviceInstanceDid: String? {
        return _serviceInstanceDid
    }

    
    private func flushDids(_ appInstanceDId: String, _ serviceInstanceDid: String) {
        _appInstanceDid = appInstanceDId
        _serviceInstanceDid = serviceInstanceDid
    }
    
    public func getStorage() -> DataStorage {
        return _dataStorage!
    }
    
    public func refreshAccessToken() throws {
        try _ = _accessToken?.fetch()
    }
    
    public func getAccessToken() -> AccessToken {
        return _accessToken!
    }
    
    public func getNodeVersion() -> Promise<NodeVersion> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try AboutController(self).getNodeVersion()
        }
    }
    
    public func getLatestCommitId() -> Promise<String> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try AboutController(self).getCommitId()!
        }
    }
}
