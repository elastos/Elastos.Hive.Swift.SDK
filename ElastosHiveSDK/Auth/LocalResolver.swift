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
import ObjectMapper

public class LocalResolver: TokenResolver {

    var nextResolver: TokenResolver?
    var dataStorage: DataStorageProtocol
    var serviceEndpoint: ServiceEndpoint
    var token: AuthToken?
    
    init(_ serviceEndpoint: ServiceEndpoint) {
        self.dataStorage = serviceEndpoint.appContext.dataStorage
        self.serviceEndpoint = serviceEndpoint
    }
    
    public func getToken() throws -> AuthToken? {
        if token == nil {
            token = try restoreToken()
        }
        if token == nil || token!.isExpired {
            token = try nextResolver!.getToken()
            try saveToken(token!)
        }
        return token
    }

    public func invlidateToken() throws {
        if token != nil {
            token = nil
            clearToken()
        }
    }
    
    public func setNextResolver(_ resolver: TokenResolver?) {
        self.nextResolver = resolver
    }
    
    public func restoreToken() throws -> AuthToken? {
        var tokenStr: String? = nil
        if self.serviceEndpoint.serviceDid != nil {
            tokenStr = self.dataStorage.loadAccessToken(serviceEndpoint.serviceDid!)
            if tokenStr == nil {
                tokenStr = self.dataStorage.loadAccessTokenByAddress(self.serviceEndpoint.providerAddress)
            }
        }
        
        if tokenStr == nil {
            return nil
        }
        
        do {
            let json: [String : Any] = try JSONSerialization.jsonObject(with: tokenStr!.data(using: .utf8)!) as! [String : Any]
            return AuthTokenToVault(JSON: json)
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    public func saveToken(_ token: AuthToken) throws {
        let tokenStr = Mapper().toJSONString(token, prettyPrint: true)
        if self.serviceEndpoint.serviceDid != nil {
            self.dataStorage.storeAccessToken(self.serviceEndpoint.serviceDid!, tokenStr!)
        }
        self.dataStorage.storeAccessTokenByAddress(self.serviceEndpoint.providerAddress, tokenStr!)
    }
    
    public func clearToken() {
        if self.serviceEndpoint.serviceDid != nil {
            self.dataStorage.clearAccessToken(self.serviceEndpoint.serviceDid!)
        }
        self.dataStorage.clearAccessTokenByAddress(self.serviceEndpoint.providerAddress)
    }
}

