import Foundation
import ElastosDIDSDK


public class DIDEntity: NSObject {
    
    var phrasepass: String
    var storepass: String

    var name: String
    var store: DIDStore?
    var did: DID?

    static var adapter: DummyAdapter?
    
    init(_ name: String, _ mnemonic: String, _ adapter: DummyAdapter, _ phrasepass: String, _ storepass: String) throws {
        self.phrasepass = phrasepass
        self.storepass = storepass
        self.name = name
        DIDEntity.adapter = adapter
        super.init()
        try initPrivateIdentity(mnemonic)
        try initDid()
    }
    
    func initPrivateIdentity(_ mnemonic: String) throws {
        let storePath = "\(NSHomeDirectory())/Library/Caches/data/didCache"
        store = try DIDStore.open(atPath: storePath, withType: "filesystem", adapter: DIDEntity.adapter!)

        if (store!.containsPrivateIdentity()) {
            return // Already exists
        }

        try store!.initializePrivateIdentity(using: Mnemonic.DID_ENGLISH, mnemonic: mnemonic, passPhrase: phrasepass, storePassword: storepass)
    }
    
    func initDid() throws {
        let dids = try store!.listDids(using: DIDStore.DID_HAS_PRIVATEKEY)
        if (dids.count > 0) {
            for did in dids {
                if did.getMetadata().aliasName == "me" {
                    print("\(name) My DID: \(did)")
                    self.did = did
                    return
                }
            }
        }

        let doc = try store!.newDid(withAlias: "me", using: storepass)
        
        self.did = doc.subject
        print("\(name) My new DID created: \(did)")
    }
    
    var getDIDStore: DIDStore {
        return store!
    }
    
    var getDid: DID {
        return did!
    }
    
    func getDocument() throws -> DIDDocument  {
        return try store!.loadDid(did!)!
    }
    
    var getName: String {
        return name
    }
    
    var getStorePassword: String {
        return storepass
    }
}

