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

public class AuthenticationServiceRender {
    private var _contextProvider: AppContextProvider?
    private var _serviceEndpoint: ServiceEndpoint

    public typealias HiveToken = String
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        self._serviceEndpoint = serviceEndpoint
        self._contextProvider = serviceEndpoint.appContext.appContextProvider
    }

    public func signInForToken() throws -> HiveToken {
        let jsonstr = self._contextProvider!.getAppInstanceDocument().description
        let data = jsonstr.data(using: .utf8)
        let json: [String: Any]  = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
        let params: [String: Any] = ["document": json]
        
        let response = try HiveAPi.request(url: self._serviceEndpoint.connectionManager.hiveApi.signIn(), method: .post, parameters: params, headers: self._serviceEndpoint.connectionManager.defaultHeaders()).get(SignInResponse.self)
        _ = try response.checkValid()
        return self._contextProvider!.getAuthorization(response.challenge)!
    }

    public func signInForIssuer() throws -> String {
        let jsonstr = self._contextProvider!.getAppInstanceDocument().description
        let data = jsonstr.data(using: .utf8)
        let json: [String: Any]  = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
        let params: [String: Any] = ["document": json]
        
        let response = try HiveAPi.request(url: self._serviceEndpoint.connectionManager.hiveApi.signIn(), method: .post, parameters: params, headers: self._serviceEndpoint.connectionManager.defaultHeaders()).get(SignInResponse.self)
         return try response.checkValid().getIssuer()!
    }
    
    public func auth(token: HiveToken) throws -> AuthToken {
        let params = ["jwt": token]
        let url = self._serviceEndpoint.connectionManager.hiveApi.auth()
        let response = try HiveAPi.request(url: url,
                                            method: .post,
                                            parameters: params,
                                            headers: self._serviceEndpoint.connectionManager.defaultHeaders()).get(AuthResponse.self)

        let jwtParserBuilder = try JwtParserBuilder().build()
        let claim = try jwtParserBuilder.parseClaimsJwt(response.accessToken).claims
        // Update the service did to service end-point for future usage.
        self._serviceEndpoint.serviceInstanceDid = claim.getIssuer()
        let expirationDate = claim.getExpiration()
        let expiresTime: Int64 = Int64(expirationDate!.timeIntervalSince1970)
        return AuthTokenToVault(response.accessToken, expiresTime)
        
    }
    
    
}
