import Foundation

public class Entity: NSObject {
    var phrasepass: String
    var storepass: String
    var name: String
    var store: DIDStore?
    var did: DID?
    var adapter: DummyAdapter
    var rootIdent: RootIdentity?
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
        store = try DIDStore.open(atPath: storePath)
        // Check the store whether contains the root private identity.
        
        guard try !store!.containsRootIdentities() else {
            rootIdent = try store?.loadRootIdentity()
            return // Already exists
        }

        // Initialize the root identity.
        rootIdent = try RootIdentity.create(mnemonic, phrasepass, store!, storepass)
        try rootIdent?.synchronize()
    }

    public func initDid() throws {
        // Check the DID store already contains owner's DID(with private key).
        let dids = try store!.listDids()
        for d in dids {
            // Already create my DID.
            print("My DID \(name) \(d)")
            self.did = d
            // This only for dummy backend.
            // normally don't need this on ID sidechain.
            let doc = try self.did?.resolve()
//            try doc?.publish(using: storepass)
            return
        }

        let doc = try rootIdent?.newDid(storepass)
        self.did = doc?.subject
        print("My new DID created: ", name, did!.description)
//        try doc?.publish(using: storepass)
    }

    public func getDocument() throws -> DIDDocument? {        return try store!.loadDid(did!)
    }
}

