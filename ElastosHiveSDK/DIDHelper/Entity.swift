import Foundation
import ElastosDIDSDK

public class Entity: NSObject {
    var phrasepass: String
    var storepass: String
    var name: String
    var store: DIDStore?
    var did: DID?
    var adapter: DummyAdapter

   public init(_ name: String, _ mnemonic: String, _ adapter: DummyAdapter, _ phrasepass: String, _ storepass: String) {
        self.phrasepass = phrasepass
        self.storepass = storepass
        self.name = name
        self.adapter = adapter
        super.init()
        do {
            try initPrivateIdentity(mnemonic)
            try initDid()
        } catch {
            print(error)
        }
    }

    public func initPrivateIdentity(_ mnemonic: String) throws {
        let storePath = "\(NSHomeDirectory())/Library/Caches/store" + "/" + name
        print(storePath)
        // Create a fake adapter, just print the tx payload to console.
        store = try DIDStore.open(atPath: storePath, withType: "filesystem", adapter: adapter)
        // Check the store whether contains the root private identity.

        guard !store!.containsPrivateIdentity() else {
            return // Already exists
        }

        // Initialize the root identity.
        try store!.initializePrivateIdentity(using: Mnemonic.DID_ENGLISH, mnemonic: mnemonic, passPhrase: phrasepass, storePassword: storepass)
    }

    public func initDid() throws {
        // Check the DID store already contains owner's DID(with private key).
        let dids = try store!.listDids(using: DIDStore.DID_HAS_PRIVATEKEY)
        for d in dids {
            // Already create my DID.
            print("My DID \(name) \(d)")
            self.did = d
            // This only for dummy backend.
            // normally don't need this on ID sidechain.
            try store!.publishDid(for: d, using: storepass)
            return
        }

        let doc = try store!.newDid(withAlias: "me", using: storepass)
        self.did = doc.subject
        print("My new DID created: ", name, did!.description)
        try store!.publishDid(for: did!, using: storepass)
    }

    public func getDocument() throws -> DIDDocument? {
        return try store!.loadDid(did!)
    }
}

