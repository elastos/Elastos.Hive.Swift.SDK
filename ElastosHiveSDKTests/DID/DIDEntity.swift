import Foundation
import ElastosDIDSDK

public class DIDEntity: NSObject {
    
    var name: String
    var phrasepass: String
    var storepass: String
    var identity: RootIdentity?
    var store: DIDStore?
    var did: DID?
    
    init(_ name: String, _ mnemonic: String, _ phrasepass: String, _ storepass: String, _ needResolve: Bool) throws {
        self.phrasepass = phrasepass
        self.storepass = storepass
        self.name = name
        super.init()
        try initDid(mnemonic, needResolve)
    }
    
    func initDid(_ mnemonic: String, _ needResolve: Bool) throws {
        let storePath = "\(NSHomeDirectory())/Library/Caches/data/didCache/" + name
        store = try DIDStore.open(atPath: storePath)
        let rootIdentity = try getRootIdentity(mnemonic)
        try initDidByRootIdentity(rootIdentity, needResolve)
    }
    
    func getRootIdentity(_ mnemonic: String) throws -> RootIdentity {
        let id = try RootIdentity.getId(mnemonic: mnemonic, passphrase: phrasepass)
        return try store!.containsRootIdentity(id) ? store!.loadRootIdentity(id)!
        : RootIdentity.create(mnemonic, phrasepass, store!, storepass)
    }
    
    func initDidByRootIdentity(_ rootIdentity: RootIdentity, _ needResolve: Bool) throws {
        let dids = try store!.listDids()
        if (dids.count > 0) {
            did = dids[0]
        } else {
            if (needResolve) {
                // Sync the all information of the did with index 0.
                let synced = try rootIdentity.synchronize(0)
                print("\(name) identity synchronized result: \(synced)")
                did = try rootIdentity.getDid(0)
            } else {
                // Only create the did on local store.
                let doc = try rootIdentity.newDid(storepass)
                did = doc.subject
                print("\(name) My new DID created: \(did)")
            }
        }
        if (did == nil) {
            throw  DIDError.UncheckedError.IllegalArgumentErrors.DIDObjectNotExistError("Can not get the did from the local store.")
        }
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

