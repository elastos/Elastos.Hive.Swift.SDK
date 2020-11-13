import Foundation
import ElastosDIDSDK

class PresentationInJWT: NSObject {
    var userDidApp: DIDApp?
    var appInstanceDidApp: DApp?
    var doc: DIDDocument?
    static var adapter: DummyAdapter = DummyAdapter()

    func initDIDBackend() throws {
        let cacheDir = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "didCache"
        try DIDBackend.initializeInstance(PresentationInJWT.adapter, cacheDir)
    }

    init(_ userDidOpt: Options, _ appInstanceDidOpt: Options) throws {
        super.init()
        try initDIDBackend()
        userDidApp = DIDApp(userDidOpt.name, userDidOpt.mnemonic, PresentationInJWT.adapter, userDidOpt.phrasepass, userDidOpt.storepass)
        appInstanceDidApp = DApp(appInstanceDidOpt.name, appInstanceDidOpt.mnemonic, PresentationInJWT.adapter, appInstanceDidOpt.phrasepass, appInstanceDidOpt.storepass)
        doc = try appInstanceDidApp!.getDocument()!
    }

    func getAuthToken(_ jwtToken: String) throws -> String {
        let claims = try JwtParserBuilder().build().parseClaimsJwt(jwtToken).claims
        let iss = claims.getIssuer()
        let nonce = claims.get(key: "nonce") as? String

        let vc = try userDidApp?.issueDiplomaFor(appInstanceDidApp!)
        let vp: VerifiablePresentation = try appInstanceDidApp!.createPresentation(vc!, iss!, nonce!)
        let token = try appInstanceDidApp!.createToken(vp, iss!)
        return token
    }
}

class Options {
    var name: String = ""
    var mnemonic: String = ""
    var phrasepass: String = ""
    var storepass: String = ""

    init() {

    }
}
