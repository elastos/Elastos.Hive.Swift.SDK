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

public class AccessToken: CodeFetcher {
    private var _jwtCode: String?
    private var _remoteFetcher: CodeFetcher?
    private var _storage: DataStorage?
    private var _endpoint: ServiceEndpoint

    
    public var flush: ((String) -> Void)?
    
    public init(_ endpoint: ServiceEndpoint, _ storage: DataStorage?) {
        _endpoint = endpoint
        _remoteFetcher = RemoteFetcher(endpoint)
        
    }
    
    public func getCanonicalizedAccessToken() -> String {
        do {
            try _jwtCode = fetch()

        } catch {
            print(error)
        }
        return "token " + _jwtCode!
    }
    
    public func fetch() throws -> String? {
        if _jwtCode != nil {
            return _jwtCode
        }

        _jwtCode = restoreToken()
        if _jwtCode == nil {
            _jwtCode = try _remoteFetcher?.fetch()

            if _jwtCode != nil {
                if self.flush != nil {
                    self.flush!(_jwtCode!)
                }
                saveToken(_jwtCode!)
            }
        } else {
            if self.flush != nil {
                self.flush!(_jwtCode!)
            }
        }
        return _jwtCode
    }
    
    public func invalidate() {
        clearToken()
    }
    
    private func restoreToken() -> String? {
        if _endpoint == nil {
            return nil
        }
        
        var jwtCode: String?
        var serviceDid: String?
        var address: String?
        
        serviceDid = _endpoint.serviceInstanceDid
        address = _endpoint.providerAddress
        
        if serviceDid != nil {
            jwtCode = _storage?.loadAccessToken(serviceDid!)
        }
        
        if jwtCode != nil && isExpired(jwtCode) {
            _storage?.clearAccessTokenByAddress(address!)
            _storage?.clearAccessToken(serviceDid!)
        }
        
        if jwtCode == nil {
            jwtCode = _storage?.loadAccessTokenByAddress(address!)
        }
        
        if jwtCode != nil && isExpired(jwtCode) {
            _storage?.clearAccessTokenByAddress(address!)
            _storage?.clearAccessToken(serviceDid!)
        }
        return jwtCode
        
    }
    
    private func isExpired(_ jwtCode: String?) -> Bool {
        return false
    }
    
    private func saveToken(_ jwtCode: String) {
        _storage?.storeAccessToken(_endpoint.serviceInstanceDid!, jwtCode);
        _storage?.storeAccessTokenByAddress(_endpoint.providerAddress, jwtCode);
    }
    
    private func clearToken() {
        _storage?.clearAccessToken(_endpoint.serviceInstanceDid!)
        _storage?.clearAccessTokenByAddress(_endpoint.providerAddress)
    }
}




