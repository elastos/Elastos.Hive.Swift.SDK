
import XCTest
import ElastosDIDSDK

public class PresentationJWT {
    private static var spvAdapter: DIDAdapter?
    public var adapter: SPVAdaptor?
    init() {
        // Get DID resolve cache dir.
        let cacheDir = "\(NSHomeDirectory())/Library/Caches/store" + "/cache"
        if PresentationJWT.spvAdapter == nil {
            let cblock: PasswordCallback = ({(walletDir, walletId) -> String in return "11111111"})
            PresentationJWT.spvAdapter = SPVAdaptor("/Users/liaihong/.wallet", "test", "TestNet", "http://api.elastos.io:21606", cblock)
        }
        adapter = (PresentationJWT.spvAdapter! as! SPVAdaptor)
//        try DIDBackend.initializeInstance("http://api.elastos.io:21606", cacheDir)
        // Dummy adapter for easy to use
        // Initializa the DID backend globally.
        try! DIDBackend.initializeInstance("http://api.elastos.io:21606", cacheDir)
    }

    func waitForWalletAvaliable() throws {
        if adapter != nil {
            while true {
                if try adapter!.isAvailable() {
                    print("OK")
                    break
                }
                else {
                    print(".")
                }
                sleep(30)
            }
        }
    }
}


public class Entity {

    let passphrase = "mypassphrase"
    let storepass = "password"
    var name: String
    var store: DIDStore?
    var did: DID?
    var adapter: SPVAdaptor

    init(_ name: String, _ mnemonic: String, _ adapter: SPVAdaptor) {
        self.name = name
        self.adapter = adapter
        try! initPrivateIdentity(mnemonic)
        try! initDid()
    }

    func initPrivateIdentity(_ mnemonic: String) throws {
        let storePath = "\(NSHomeDirectory())/Library/Caches/store" + "/" + name
        // Create a fake adapter, just print the tx payload to console.
        store = try DIDStore.open(atPath: storePath, withType: "filesystem", adapter: adapter)
        // Check the store whether contains the root private identity.

        guard !store!.containsPrivateIdentity() else {
            return // Already exists
        }
        // Create a mnemonic use language(English).english
        let mnemonic = try Mnemonic.generate("english")
        print("[%s] Please write down your mnemonic and passwords:%n", name)
        print("  Mnemonic: " + mnemonic)
        print("  Mnemonic passphrase: " + passphrase)
        print("  Store password: " + storepass)

        // Initialize the root identity.
        try store!.initializePrivateIdentity(using: Mnemonic.ENGLISH, mnemonic: mnemonic, passPhrase: passphrase, storePassword: storepass)
        try waitForWalletAvaliable()
    }

    func waitForWalletAvaliable() throws {
        while true {
            if try adapter.isAvailable() {
                print("OK")
                break
            }
            else {
                print(".")
            }
            sleep(30)
        }
    }

    func initDid() throws {
        // Check the DID store already contains owner's DID(with private key).
        let dids = try store!.listDids(using: DIDStore.DID_HAS_PRIVATEKEY)
        try dids.forEach { d in
            if d.getMetadata().aliasName == "me" {
                // Already create my DID.
                print("My DID \(name) \(d)")

                // This only for dummy backend.
                // normally don't need this on ID sidechain.
                try store!.publishDid(for: d, using: storepass)
                try waitForWalletAvaliable()
            }
        }
        let doc = try store!.newDid(withAlias: "me", using: storepass)
        self.did = doc.subject
        print("My new DID created: ", name, did!.description)
        try store!.publishDid(for: did!, using: storepass)
        try waitForWalletAvaliable()
    }

    func getDocument() throws -> DIDDocument {
        return try store!.loadDid(did!)!
    }
}

public class DIDApp: Entity {
    var issuer: VerifiableCredentialIssuer?

    override init(_ name: String, _ mnemonic: String, _ adapter: SPVAdaptor) {
        super.init(name, mnemonic, adapter)
        issuer = try! VerifiableCredentialIssuer(getDocument())
    }


    func issueDiplomaFor(_ dapp: DApp) throws -> VerifiableCredential {
        let subject = ["'appDid'": dapp.appId]
        let userCalendar = Calendar.current
        var components = DateComponents()
        components.year = 2025
        let exp = userCalendar.date(from: components)
        let cb = issuer!.editingVerifiableCredentialFor(did: dapp.did!)
        let vc = try cb.withId("didapp")
            .withTypes("AppIdCredential")
            .withProperties(subject)
            .withExpirationDate(exp!)
            .sealed(using: storepass)

        print("VerifiableCredential:")
        let vcStr = vc.toString(true)
        print(vcStr)

        return vc
    }

}

public class DApp: Entity {
    let appId = "appId"

    override init(_ name: String, _ mnemonic: String, _ adapter: SPVAdaptor) {
        super.init(name, mnemonic, adapter)
    }

    func createPresentation(_ vc: VerifiableCredential, _ realm: String, _ nonce: String) throws -> VerifiablePresentation {
        let vpb = try VerifiablePresentation.editingVerifiablePresentation(for: did!, using: store!)
        let vcs = [vc]

        let vp = try vpb.withCredentials(vcs)
            .withRealm(realm)
            .withNonce(nonce)
            .sealed(using: storepass)
        print("VerifiableCredential: ")
        print(vp.description)

        return vp
    }

    func createToken(_ vp: VerifiablePresentation, _ hiveDid: String) throws -> String {
        let iat = Date()
        let nbf = iat
        let userCalendar = Calendar.current
        var components = DateComponents()
        components.year = 2023
        let exp = userCalendar.date(from: components)

        // Create JWT token with presentation.
        let token = try getDocument().jwtBuilder()
            .addHeader(key: Header.TYPE, value: Header.JWT_TYPE)
            .addHeader(key: "version", value: "1.0")
            .setSubject(sub: "DIDAuthResponse")
            .setAudience(audience: hiveDid)
            .setIssuedAt(issuedAt: iat)
            .setExpiration(expiration: exp!)
            .setNotBefore(nbf: nbf)
            .claimWithJson(name: "presentation", jsonValue: vp.description)
            .sign(using: storepass)
            .compact()
        print("JWT Token:")
        print("   \(token)")

        return token
    }
}

