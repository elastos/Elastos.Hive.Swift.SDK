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

public class AuthenticationServiceRender: HiveVaultRender {
    private var _contextProvider: AppContextProvider?
    
    public typealias HiveToken = String
    
    public override init(_ serviceEndpoint: ServiceEndpoint) {
        super.init(serviceEndpoint)
        self._contextProvider = serviceEndpoint.appContext.appContextProvider
    }

    public func signInForToken() throws -> HiveToken {
        let jsonstr = self._contextProvider!.getAppInstanceDocument()!.description
        let data = jsonstr.data(using: .utf8)
        let json: [String: Any]  = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
        let params: [String: Any] = ["document": json]
        
        let response = try HiveAPi.request(url: self.connectionManager.hiveApi.signIn(), method: .post, parameters: params, headers: self.connectionManager.NormalHeaders()).get(SignInResponse.self)
        _ = try response.checkValid()
        return self._contextProvider!.getAuthorization(response.challenge)!
    }

    public func signInForIssuer() throws -> String {
        let jsonstr = self._contextProvider!.getAppInstanceDocument()!.description
        let data = jsonstr.data(using: .utf8)
        let json: [String: Any]  = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
        let params: [String: Any] = ["document": json]
        
        let response = try HiveAPi.request(url: self.connectionManager.hiveApi.signIn(), method: .post, parameters: params, headers: self.connectionManager.NormalHeaders()).get(SignInResponse.self)
         return try response.checkValid().getIssuer()!
    }
    
    public func auth(token: HiveToken) throws -> AuthToken {
        let params = ["jwt": token]
        let url = self.connectionManager.hiveApi.auth()
        let response = try HiveAPi.request(url: url,
                                            method: .post,
                                            parameters: params,
                                            headers: self.connectionManager.NormalHeaders()).get(AuthResponse.self)

        let jwtParserBuilder = try JwtParserBuilder().build()
        let claim = try jwtParserBuilder.parseClaimsJwt(response.accessToken).claims
        let expirationDate = claim.getExpiration()
        let expiresTime = 9234999999
//        let expiresTime: String = Date.convertToUTCStringFromDate(expirationDate!)
        return AuthToken(response.accessToken, Int64(expiresTime), "token")
        
    }
    
    
}
