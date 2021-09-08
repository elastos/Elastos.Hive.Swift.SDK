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

/**
 * The access token is made by hive node and represents the user DID and the application DID.
 *
 * Some of the node APIs requires access token when handling request.
 */
public class AccessToken: CodeFetcher {
    private var _jwtCode: String?
    private var _remoteFetcher: CodeFetcher?
    private var _storage: DataStorage?
    private var _endpoint: ServiceEndpoint
    
    // The bridge handle is used for caller to do sth when getting the access token.
    public var flush: ((String) -> Void)?
    
    /// Create the access token by service end point, data storage, and bridge handler.
    ///
    /// - parameters:
    ///   - endpoint: The service end point.
    ///   - storage: The data storage which is used to save the access token.
    public init(_ endpoint: ServiceEndpoint, _ storage: DataStorage?) {
        _endpoint = endpoint
        _remoteFetcher = RemoteFetcher(endpoint)
        _storage = storage        
    }
    
    /// Get the access token without exception.
    ///
    /// - returns: null if not exists.
    public func getCanonicalizedAccessToken() throws -> String {
        try _jwtCode = fetch()
        return "token " + _jwtCode!
    }
    
    /// Fetch the code.
    /// - Throws: NodeRPCError The exception shows the error returned by hive node.
    /// - Returns: The code.
    public func fetch() throws -> String? {
        if _jwtCode != nil {
            return _jwtCode
        }

        _jwtCode = try restoreToken()
        if _jwtCode == nil {
            _jwtCode = try _remoteFetcher?.fetch()

            if _jwtCode != nil {
                if self.flush != nil {
                    self.flush!(_jwtCode!)
                }
                try saveToken(_jwtCode!)
            }
        } else {
            if self.flush != nil {
                self.flush!(_jwtCode!)
            }
        }
        return _jwtCode
    }
    
    /// Invalidate the code for getting the code from remote server.
    public func invalidate() throws {
        try clearToken()
    }
    
    private func restoreToken() throws -> String? {
        if _endpoint == nil {
            return nil
        }
        
        var jwtCode: String?
        var serviceDid: String?
        var address: String?
        
        serviceDid = _endpoint.serviceInstanceDid
        address = _endpoint.providerAddress
        
        if serviceDid != nil {
            jwtCode = try _storage?.loadAccessToken(serviceDid!)
        }
        
        if jwtCode != nil && isExpired(jwtCode) {
            try _storage?.clearAccessTokenByAddress(address!)
            try _storage?.clearAccessToken(serviceDid!)
        }
        
        if jwtCode == nil {
            jwtCode = try _storage?.loadAccessTokenByAddress(address!)
        }
        
        if jwtCode != nil && isExpired(jwtCode) {
            try _storage?.clearAccessTokenByAddress(address!)
            try _storage?.clearAccessToken(serviceDid!)
        }
        return jwtCode
    }
    
    private func isExpired(_ jwtCode: String?) -> Bool {
        return false
    }
    
    private func saveToken(_ jwtCode: String) throws {
        try _storage?.storeAccessToken(_endpoint.serviceInstanceDid!, jwtCode);
        try _storage?.storeAccessTokenByAddress(_endpoint.providerAddress, jwtCode);
    }
    
    private func clearToken() throws {
        try _storage?.clearAccessToken(_endpoint.serviceInstanceDid!)
        try _storage?.clearAccessTokenByAddress(_endpoint.providerAddress)
    }
}




