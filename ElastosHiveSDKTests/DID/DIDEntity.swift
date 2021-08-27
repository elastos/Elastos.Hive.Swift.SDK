import Foundation
import ElastosDIDSDK

public class DIDEntity: NSObject {
    
    var name: String
    var phrasepass: String
    var storepass: String
    var identity: RootIdentity?
    var store: DIDStore?
    var did: DID?
    
    init(_ name: String, _ mnemonic: String, _ phrasepass: String, _ storepass: String) throws {
        self.phrasepass = phrasepass
        self.storepass = storepass
        self.name = name
        super.init()
        try initPrivateIdentity(mnemonic)
        try initDid()
    }
    
    func initPrivateIdentity(_ mnemonic: String) throws {
        let storePath = "\(NSHomeDirectory())/Library/Caches/data/didCache/" + name
        store = try DIDStore.open(atPath: storePath)
//        identity = try store?.loadRootIdentity()
        if (try store!.containsRootIdentities()) {
            return // Already exists
        }

        identity = try RootIdentity.create(mnemonic, phrasepass, store!, storepass)
        let re = try identity?.synchronize(0)
        print(re)
    }
    
    func initDid() throws {
        let dids = try store!.listDids()
        if (dids.count > 0) {
            self.did = dids[0]
        }

        if let doc = try identity?.newDid(storepass) {
            self.did = doc.subject
        }
        print("My new DID created: ", name, did!.description)
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
    
    public override var description: String {
        
        return did!.description
    }
}

