import Foundation
import ElastosDIDSDK
import PromiseKit

public class PresentationInJWT: NSObject {
    var userDidApp: DIDApp?
    var appInstanceDidApp: DApp?
    var doc: DIDDocument?
    static var adapter: DummyAdapter = DummyAdapter()
    var backupOptions: BackupOptions

    public func initDIDBackend() throws {
        let cacheDir = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "didCache"
        try DIDBackend.initializeInstance(PresentationInJWT.adapter, cacheDir)
    }

    public init(_ userDidOpt: AppOptions, _ appInstanceDidOpt: AppOptions, _ backupOptions: BackupOptions) throws {
        self.backupOptions = backupOptions
        super.init()
        try initDIDBackend()
        userDidApp = DIDApp(userDidOpt.name, userDidOpt.mnemonic, PresentationInJWT.adapter, userDidOpt.phrasepass, userDidOpt.storepass)
        appInstanceDidApp = try! DApp(appInstanceDidOpt.name, appInstanceDidOpt.mnemonic, PresentationInJWT.adapter, appInstanceDidOpt.phrasepass, appInstanceDidOpt.storepass)
        doc = try appInstanceDidApp!.getDocument()
    }
   
    public func getDoc() -> DIDDocument {
        return doc!
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
   
    public func getBackupVc(_ sourceDID: String) throws -> String {
        let vc = try userDidApp?.issueBackupDiplomaFor(sourceDID, backupOptions.targetHost, backupOptions.targetDID)
        print(vc?.description)
        return vc!.description
    }
    
    public var targetHost: String {
        return backupOptions.targetHost
    }

    public var targetDid: String {
        return backupOptions.targetDID
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

public class AppOptions {
    var name: String = ""
    var mnemonic: String = ""
    var phrasepass: String = ""
    var storepass: String = ""

    init() { }
}

public class BackupOptions {
    var targetDID: String = ""
    var targetHost: String = ""
    
    init() { }
}

