
import Foundation
import ElastosHiveSDK

public class TestAppContextProvider: AppContextProvider {
    public func getAuthorization(_ authenticationChallengeJWTcode: String) -> Promise<String>? {
        return Promise<String> { resolver in
            resolver.fulfill(signAuthorization(authenticationChallengeJWTcode)!)
        }
    }
    
    public var appInstanceDid: AppDID
    public var userDid: UserDID
    private var localDataDir: String

    public func getLocalDataDir() -> String? {
        self.localDataDir
    }
    
    public func getAppInstanceDocument() -> DIDDocument? {
        return try! appInstanceDid.getDocument()
    }
    
    init(_ path: String, _ userDid: UserDID, _ appInstanceDid: AppDID) {
        self.localDataDir = path
        self.userDid = userDid
        self.appInstanceDid = appInstanceDid
    }
    
    public func signAuthorization(_ jwtToken: String) -> String? {
        
        var accessToken: String?
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async { [self] in
            do {
                let claims = try JwtParserBuilder().build().parseClaimsJwt(jwtToken).claims
                let iss = claims.getIssuer()
                let nonce = claims.get(key: "nonce") as? String
                
                let vc = try userDid.issueDiplomaFor(appInstanceDid)
                let vp: VerifiablePresentation = try appInstanceDid.createPresentation(vc, iss!, nonce!)
                let token = try appInstanceDid.createToken(vp, iss!)
                accessToken = token
                semaphore.signal()
            } catch{
                print(error)
                semaphore.signal()
            }
        }
        semaphore.wait()
        return accessToken!
    }
}
