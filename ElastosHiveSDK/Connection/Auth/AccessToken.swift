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
    private var _remoteFetcher: CodeFetcher
    private var _storage: DataStorage?
    private var _endpoint: ServiceEndpoint
    private var _storageKey: String

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
        self._storageKey = ""
    }
    
    private func getStorageKey() -> String {
        if (self._storageKey == "") {
            let userDid = (self._endpoint.userDid != nil) ? self._endpoint.userDid! : ""
            let appDid = (self._endpoint.appDid != nil) ? self._endpoint.appDid : ""
            let hiveUrl = self._endpoint.providerAddress
            let key = userDid + ";" + appDid + ";" + hiveUrl
            self._storageKey = key.sha256
        }
        return self._storageKey
    }

    /// Fetch the code.
    /// - Throws: NodeRPCError The exception shows the error returned by hive node.
    /// - Returns: The code.
    public func fetch() throws -> String? {
        if _jwtCode != nil {
            return _jwtCode
        }
        
        // TODO:
        objc_sync_enter(self)
        _jwtCode = try restoreToken()
        if (_jwtCode != nil) {
            self.flush?(_jwtCode!)
        }
        _jwtCode = try self.fetchFromRemote()
        objc_sync_exit(self)
        
        return _jwtCode
    }
    
    private func fetchFromRemote() throws -> String? {
        let token = try self._remoteFetcher.fetch()
        if token != nil {
            self.flush?(token!)
            try saveToken(token!)
        }

        return token
    }
    
    /// Invalidate the code for getting the code from remote server.
    public func invalidate() throws {
        try clearToken()
    }
    
    private func restoreToken() throws -> String? {
        let key = self.getStorageKey()
        _jwtCode = try _storage?.loadAccessToken(key)

        if _jwtCode != nil && isExpired(_jwtCode) {
            try _storage?.clearAccessToken(key)
        }
        return _jwtCode
    }
    
    private func isExpired(_ jwtCode: String?) -> Bool {
        
        do {
            let claims = try JwtParserBuilder().setAllwedClockSkewSeconds(300).build().parseClaimsJwt(jwtCode!).claims
            
            let expirationTime = claims.getExpiration()
            let currentTime = Date()
            return currentTime > expirationTime!
        } catch {
            return true
        }

        return false
    }
    
    private func saveToken(_ jwtCode: String) throws {
        let key = self.getStorageKey()
        try _storage?.storeAccessToken(key, jwtCode)

    }
    
    private func clearToken() throws {
        let key = self.getStorageKey()
        try _storage?.clearAccessToken(key)
    }
    
    func synchronized<T>( _ action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }
}




