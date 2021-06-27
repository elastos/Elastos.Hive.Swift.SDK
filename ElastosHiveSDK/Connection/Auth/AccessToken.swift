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

public class AccessToken: CodeFetcherProtocol {
    private var _jwtCode: String?
    private var _remoteFetcher: CodeFetcherProtocol?
    private var _storage: DataStorageProtocol?
    private var _bridge: BridgeHandlerProtocol?
    
    public init(_ endpoint: ServiceEndpoint, _ storage: DataStorageProtocol?, _ bridge: BridgeHandlerProtocol?) {
        _remoteFetcher = RemoteFetcher(endpoint)
        
    }
    
    public func getCanonicalizedAccessToken() -> String {
        
    }
    
    public func fetch() throws -> String? {
        if _jwtCode != nil {
            return _jwtCode
        }
        
        _jwtCode = restoreToken()
        if _jwtCode == nil {
            _jwtCode = try _remoteFetcher?.fetch()
            
            if _jwtCode != nil {
                _bridge?.flush(_jwtCode)
                saveToken(_jwtCode)
            }
        } else {
            _bridge?.flush(_jwtCode)
        }
        return _jwtCode
    }
    
    public func invalidate() {
        clearToken()
    }
    
    private func restoreToken() -> String? {
        
        let endpoint: ServiceEndpoint = _bridge?.target() as! ServiceEndpoint
        if endpoint == nil {
            return nil
        }
        
        var jwtCode: String = nil
        var serviceDid: String
        var address: String
//
//                serviceDid = endpoint.getServiceInstanceDid();
//                address    = endpoint.getProviderAddress();
//
//                if (serviceDid != null)
//                    jwtCode = storage.loadAccessToken(serviceDid);
//
//                if (jwtCode != null && isExpired(jwtCode)) {
//                    storage.clearAccessTokenByAddress(address);
//                    storage.clearAccessToken(serviceDid);
//                }
//
//                if (jwtCode == null)
//                    jwtCode = storage.loadAccessTokenByAddress(address);
//
//
//                if (jwtCode != null && isExpired(jwtCode)) {
//                    storage.clearAccessTokenByAddress(address);
//                    storage.clearAccessToken(serviceDid);
//                }
//
//                return jwtCode;
    }
    
    private func isExpired(_ jwtCode: String?) -> Bool? {
        return false
    }
    
    private func saveToken(_ jwtCode: String?) {
        
    }
    
    private func clearToken() {
 
    }

    
//    public AccessToken(ServiceEndpoint endpoint, DataStorage storage, BridgeHandler bridge) {
//            remoteFetcher = new RemoteFetcher(endpoint);
//            this.storage = storage;
//            this.bridge = bridge;
//        }
//
//        public String getCanonicalizedAccessToken() {
//            try {
//                jwtCode = fetch();
//            } catch (Exception e) {
//                // TODO:
//                return null;
//            }
//            return "token " + jwtCode;
//        }
//
//        @Override
//        public String fetch() throws NodeRPCException {
//            if (jwtCode != null)
//                return jwtCode;
//
//            jwtCode = restoreToken();
//            if (jwtCode == null) {
//                jwtCode = remoteFetcher.fetch();
//
//                if (jwtCode != null) {
//                    bridge.flush(jwtCode);
//                    saveToken(jwtCode);
//                }
//            } else {
//                bridge.flush(jwtCode);
//            }
//            return jwtCode;
//        }
//
//        @Override
//        public void invalidate() {
//            clearToken();
//        }
//
//        private String restoreToken() {
//            ServiceEndpoint endpoint = (ServiceEndpoint)bridge.target();
//            if (endpoint == null)
//                return null;
//
//            String jwtCode = null;
//            String serviceDid;
//            String address;
//
//            serviceDid = endpoint.getServiceInstanceDid();
//            address    = endpoint.getProviderAddress();
//
//            if (serviceDid != null)
//                jwtCode = storage.loadAccessToken(serviceDid);
//
//            if (jwtCode != null && isExpired(jwtCode)) {
//                storage.clearAccessTokenByAddress(address);
//                storage.clearAccessToken(serviceDid);
//            }
//
//            if (jwtCode == null)
//                jwtCode = storage.loadAccessTokenByAddress(address);
//
//
//            if (jwtCode != null && isExpired(jwtCode)) {
//                storage.clearAccessTokenByAddress(address);
//                storage.clearAccessToken(serviceDid);
//            }
//
//            return jwtCode;
//        }
//
//        private boolean isExpired(String jwtCode) {
//            // return System.currentTimeMillis() >= (getExpiresTime() * 1000);
//            return false;
//        }
//
//        private void saveToken(String jwtCode) {
//            ServiceEndpoint endpoint = (ServiceEndpoint)bridge.target();
//            if (endpoint == null)
//                return;
//
//            storage.storeAccessToken(endpoint.getServiceInstanceDid(), jwtCode);
//            storage.storeAccessTokenByAddress(endpoint.getProviderAddress(), jwtCode);
//        }
//
//        private void clearToken() {
//            ServiceEndpoint endpoint = (ServiceEndpoint)bridge.target();
//            if (endpoint == null)
//                return;
//
//            storage.clearAccessToken(endpoint.getServiceInstanceDid());
//            storage.clearAccessTokenByAddress(endpoint.getProviderAddress());
//        }
}




