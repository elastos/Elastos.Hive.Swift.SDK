
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

public class UserFactory {
    static let didCachePath = "didCache"
    var vault: Vault?
    var resolverDidSetup = false
    var presentationInJWT: PresentationInJWT?
    var client: HiveClientHandle
    var storePath: String
    var ownerDid: String
    var resolveUrl: String
    var provider: String

    init(_ userDidOpt: Options,
         _ appInstanceDidOpt: Options,
         _ ownerDid: String,
         _ resolveUrl: String,
         _ provider: String,
         _ tokenCachePath: String) throws {
        self.storePath = tokenCachePath
        self.ownerDid = ownerDid
        self.resolveUrl = resolveUrl
        self.provider = provider
        presentationInJWT = try PresentationInJWT(userDidOpt, appInstanceDidOpt)
        if !resolverDidSetup {
            try HiveClientHandle.setupResolver(resolveUrl, UserFactory.didCachePath)
            resolverDidSetup = true
        }
        let options = HiveClientOptions()
        _ = options.setLocalDataPath(tokenCachePath)
        _ = options.setAuthenticator(VaultAuthenticator())
        _ = options.setAuthenticationDIDDocument((presentationInJWT?.doc)!)
        client = try HiveClientHandle.createInstance(withOptions: options)
    }
    
    class func createFactory(_ userDidOpt: Options,
                             _ appInstanceDidOpt: Options,
                             _ ownerDid: String,
                             _ resolveUrl: String,
                             _ provider: String,
                             _ tokenCachePath: String) throws -> UserFactory {
        return try UserFactory(userDidOpt, appInstanceDidOpt,ownerDid, resolveUrl,provider, tokenCachePath)
    }

    class func createUser1() throws -> UserFactory {
        let user2path = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "user1"
        let userDidOpt = Options()
        userDidOpt.name = userDid1_name
        userDidOpt.mnemonic = userDid1_mn
        userDidOpt.phrasepass = userDid1_phrasepass
        userDidOpt.storepass = userDid1_storepass

        let appInstanceDidOpt = Options()
        appInstanceDidOpt.name = appInstance1_name
        appInstanceDidOpt.mnemonic = appInstance1_mn
        appInstanceDidOpt.phrasepass = appInstance1_phrasepass
        appInstanceDidOpt.storepass = appInstance1_storepass
        return try UserFactory(userDidOpt, appInstanceDidOpt, userDid2, TEST_RESOLVER_URL, DEVELOP_PROVIDER, user2path)
    }

    class func createUser2() throws -> UserFactory {
        let user1Path = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "user2"
        let userDidOpt = Options()
        userDidOpt.name = userDid2_name
        userDidOpt.mnemonic = userDid2_mn
        userDidOpt.phrasepass = userDid2_phrasepass
        userDidOpt.storepass = userDid2_storepass

        let appInstanceDidOpt = Options()
        appInstanceDidOpt.name = appInstance2_name
        appInstanceDidOpt.mnemonic = appInstance2_mn
        appInstanceDidOpt.phrasepass = appInstance2_phrasepass
        appInstanceDidOpt.storepass = appInstance2_storepass

        return try UserFactory(userDidOpt, appInstanceDidOpt,userDid2, MAIN_RESOLVER_URL, RELEASE_PROVIDER, user1Path)
    }
}
