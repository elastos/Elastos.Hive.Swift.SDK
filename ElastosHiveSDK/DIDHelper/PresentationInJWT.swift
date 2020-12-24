import Foundation
import ElastosDIDSDK
import PromiseKit

public class PresentationInJWT: NSObject {
    var userDidApp: DIDApp?
    var appInstanceDidApp: DApp?
    var doc: DIDDocument?
    static var adapter: DummyAdapter = DummyAdapter()

    public func initDIDBackend() throws {
        let cacheDir = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "didCache"
        try DIDBackend.initializeInstance(PresentationInJWT.adapter, cacheDir)
    }

    public init(_ userDidOpt: PresentationInJWTOptions, _ appInstanceDidOpt: PresentationInJWTOptions) throws {
        super.init()
        try initDIDBackend()
        userDidApp = DIDApp(userDidOpt.name, userDidOpt.mnemonic, PresentationInJWT.adapter, userDidOpt.phrasepass, userDidOpt.storepass)
        appInstanceDidApp = DApp(appInstanceDidOpt.name, appInstanceDidOpt.mnemonic, PresentationInJWT.adapter, appInstanceDidOpt.phrasepass, appInstanceDidOpt.storepass)
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
