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

public class AuthController {
    private var _connectionManager: ConnectionManager
    private var _expectationAudience: String
    
    public init(_ serviceEndpoint: ServiceEndpoint, _ appInstanceDidDoc: DIDDocument) {
        _connectionManager = serviceEndpoint.connectionManager!
        _expectationAudience = appInstanceDidDoc.subject.description
    }
    
    private func convertStringToDictionary(text: String) throws -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
            return json
        }
        return nil
   }
    
    public func signIn(_ appInstanceDidDoc: DIDDocument) throws -> String? {
        let challenge: ChallengeRequest = try _connectionManager.signIn(SignInRequest(self.convertStringToDictionary(text: appInstanceDidDoc.description))).execute(ChallengeRequest.self)
        if try !checkValid(challenge.getChallenge, _expectationAudience) {
            throw HiveError.ServerUnkownException("Invalid challenge code, possibly being hacked.")
        }
        return challenge.getChallenge
    }
    
    public func auth(_ challengeResponse: String) throws -> String? {
        let token: AccessCode = try _connectionManager.auth(ChallengeResponse(challengeResponse)).execute(AccessCode.self)
        
        if try !checkValid(token.getToken, _expectationAudience) {
            throw HiveError.ServerUnkownException("Invalid challenge code, possibly being hacked.")
        }
       
        return token.getToken
    }

    private func checkValid(_ jwtCode: String, _ expectationDid: String) throws -> Bool {
        let jwtParserBuilder = try JwtParserBuilder().build()
        let claim = try jwtParserBuilder.parseClaimsJwt(jwtCode).claims

        return claim.getExpiration()! > Date() && claim.getAudience() == expectationDid
    }
}
