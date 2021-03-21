import Foundation
import ElastosDIDSDK

public class Entity: NSObject {
    var phrasepass: String
    var storepass: String
    var name: String
    var store: DIDStore?
    var did: DID?
    static var adapter: DummyAdapter?

   public init(_ name: String, _ mnemonic: String, _ adapter: DummyAdapter, _ phrasepass: String, _ storepass: String) {
        self.phrasepass = phrasepass
        self.storepass = storepass
        self.name = name
    Entity.adapter = adapter
        super.init()
        do {
            try initPrivateIdentity(mnemonic)
            try initDid()
        } catch {
            print(error)
        }
    }

    public func initPrivateIdentity(_ mnemonic: String) throws {
        let storePath = "\(NSHomeDirectory())/Library/Caches/data/didCache" + "/" + name
        print(storePath)
        // Create a fake adapter, just print the tx payload to console.
        store = try DIDStore.open(atPath: storePath, withType: "filesystem", adapter: Entity.adapter!)
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
//             Already create my DID.
//            print("My DID \(name) \(d)")
//            self.did = d
//            // This only for dummy backend.
//            // normally don't need this on ID sidechain.
//            try store!.publishDid(for: d, using: storepass)
            if d.getMetadata().aliasName == "me" {
                print("\(name) My DID: \(d)")
                self.did = d
            }
            return
        }

        let doc = try store!.newDid(withAlias: "me", using: storepass)
        self.did = doc.subject
        print(name + " My new DID created: ", did!.description)
//        try store!.publishDid(for: did!, using: storepass)
    }

    public func getDIDStore() -> DIDStore? {
        return store
    }
    
    public func getDid() throws -> DID? {
        return did
    }
    
    public func getDocument() throws -> DIDDocument? {
        return try store!.loadDid(did!)
    }

    public func getName() throws -> String {
        return name
    }
    
    public func getStorePassword() throws -> String {
        return storepass
    }
}

