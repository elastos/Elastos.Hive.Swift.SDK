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
import ObjectMapper

public class RemoteResolver: TokenResolver {
    private var _contextProvider: AppContextProvider
    private var _authenticationServiceRender: AuthenticationServiceRender
    
    public init (_ serviceEndpoint: ServiceEndpoint) {
        self._contextProvider = serviceEndpoint.appContext.appContextProvider
        self._authenticationServiceRender = AuthenticationServiceRender(serviceEndpoint)
    }


    public func getToken() throws -> AuthToken? {
        return try self._authenticationServiceRender.auth(token: self._authenticationServiceRender.signInForToken())
    }

    public func invlidateToken() throws {

    }

    public func setNextResolver(_ resolver: TokenResolver?) {

    }
//
//    private func signIn() throws -> String {
//        let jsonstr = self.contextProvider.getAppInstanceDocument()!.description
//        let data = jsonstr.data(using: .utf8)
//        let json: [String: Any]  = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
//        let params: [String: Any] = ["document": json]
//        let responseJson: HiveResponse = try HiveAPi.request(url: self.connectionManager.hiveApi.signIn(),
//                                                             method: .post,
//                                                             parameters: params,
//                                                             headers: self.connectionManager.NormalHeaders()).get()
//
//        let jwtToken: String = responseJson.json["challenge"] as! String
//
//        guard jwtToken != "" else {
//            throw HiveError.challengeIsNil(des: "Sign-in request failed")
//        }
//        _ = try verifyToken(jwtToken)
//        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
//        var authToken = ""
//        self.contextProvider.getAuthorization(jwtToken)!.done { token in
//            authToken = token
//            semaphore.signal()
//        }.catch { error in
//            // TODO: ERROR
//            semaphore.signal()
//        }
//        semaphore.wait()
//
//        return authToken
//    }
//
//    private func verifyToken(_ jwtToken: String) throws -> Bool {
//
//        let jwtParser = try JwtParserBuilder().build()
//        let claims = try jwtParser.parseClaimsJwt(jwtToken).claims
//        let exp = claims.getExpiration()
//        let aud = claims.getAudience()
//        let did = self.contextProvider.getAppInstanceDocument()!.subject.description
//        if aud == nil || did != aud! {
//            throw HiveError.jwtVerify(des: "authenticationDIDDocument's subject is not equal to audience")
//        }
//        let currentTime = Date()
//        guard let _ = exp else {
//            return false
//        }
//        return currentTime > exp!
//    }
//
//    private func auth(_ token: String) throws -> AuthToken {
//        let params = ["jwt": token]
//        let url = self.connectionManager.hiveApi.auth()
//        let response = try HiveAPi.request(url: url,
//                                            method: .post,
//                                            parameters: params,
//                                            headers: self.connectionManager.NormalHeaders()).get()
//        // TODO:
//        let accessToken: String = response.json["access_token"] as! String
//        let jwtParserBuilder = try JwtParserBuilder().build()
//        let claim = try jwtParserBuilder.parseClaimsJwt(accessToken).claims
//        let expirationDate = claim.getExpiration()
//        let expiresTime = 9234999999
////        let expiresTime: String = Date.convertToUTCStringFromDate(expirationDate!)
//        return AuthToken(accessToken, expiresTime, "token")
//    }
//
//    private func handleAuthResponse(_ response: JSON) throws -> AuthToken {
//        let accessToken = response["access_token"].stringValue
//        let jwtParserBuilder = try JwtParserBuilder().build()
//        let claim = try jwtParserBuilder.parseClaimsJwt(accessToken).claims
//        let expirationDate = claim.getExpiration()
//        let expiresTime = 9234999999
////        let expiresTime: String = Date.convertToUTCStringFromDate(expirationDate!)
//        // TODO:
//        return AuthToken(accessToken, expiresTime, "token")
//    }
//
//    private func challengeResponse() throws -> String {
//        let response = AF.request(self.connectionManager.hiveApi.auth(),
//                                  method:.post,
//                                  encoding:JSONEncoding.default).responseJSON()
//
//        var token: AccessToken? = nil
//        switch response.result {
//        case .success(let json):
//            token = AccessToken(JSON: json as! [String : Any])!
//            break
//        case .failure(let error):
//            throw error
//        }
//
//        guard token?.accessToken != nil else {
//            throw HiveError.IllegalArgument(des: "invalid token")
//        }
//
//        guard try verifyToken((token?.accessToken)!) else {
//            throw HiveError.IllegalArgument(des: "invalid token")
//        }
//
//        return token!.accessToken!
//    }
}
