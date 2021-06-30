import Foundation
import PromiseKit

public class PresentationInJWT: NSObject {
    var userDidApp: DIDApp?
    var appInstanceDidApp: DApp?
    var doc: DIDDocument?
    var adapter: DummyAdapter

    public func initDIDBackend(_ adapter: DummyAdapter) throws {
        self.adapter = adapter
        try DIDBackend.initialize(adapter)
    }

    public init(_ userDidOpt: PresentationInJWTOptions, _ appInstanceDidOpt: PresentationInJWTOptions, _ adapter: DummyAdapter) throws {
        self.adapter = adapter
        super.init()
        try initDIDBackend(adapter)
        userDidApp = DIDApp(userDidOpt.name, userDidOpt.mnemonic, adapter, userDidOpt.phrasepass, userDidOpt.storepass)
        appInstanceDidApp = DApp(appInstanceDidOpt.name, appInstanceDidOpt.mnemonic, adapter, appInstanceDidOpt.phrasepass, appInstanceDidOpt.storepass)
        doc = try appInstanceDidApp!.getDocument()!
    }
    
    public func getAuthToken(_ jwtToken: String) -> Promise<String> {
        return Promise{ resolver in
            DispatchQueue.global().async { [self] in
                do {
                    let claims = try JwtParserBuilder().build().parseClaimsJwt(jwtToken).claims
                    let iss = claims.getIssuer()
                    let nonce = claims.get(key: "nonce") as? String
                    
                    let vc = try userDidApp?.issueDiplomaFor(appInstanceDidApp!)
                    let vp: VerifiablePresentation = try appInstanceDidApp!.createPresentation(vc!, iss!, nonce!)
                    let token = try appInstanceDidApp!.createToken(vp, iss!)
                    resolver.fulfill(token)
                }
                catch{
                    resolver.reject(error)
                }
            }
        }
    }
    
  /*func getAuthToken(_ jwtToken: String) throws -> String {
        let claims = try JwtParserBuilder().build().parseClaimsJwt(jwtToken).claims
        let iss = claims.getIssuer()
        let nonce = claims.get(key: "nonce") as? String

        let vc = try userDidApp?.issueDiplomaFor(appInstanceDidApp!)
        let vp: VerifiablePresentation = try appInstanceDidApp!.createPresentation(vc!, iss!, nonce!)
        let token = try appInstanceDidApp!.createToken(vp, iss!)
        return token
    }*/
}

public class PresentationInJWTOptions {
    var name: String = ""
    var mnemonic: String = ""
    var phrasepass: String = ""
    var storepass: String = ""

    init() {

    }
}
