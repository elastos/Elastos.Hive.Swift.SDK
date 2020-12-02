
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
         _ provider: String,
         _ resolveUrl: String,
         _ ownerDid: String,
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
    
    //release环境（MainNet + https://hive1.trinity-tech.io + userDid1）
    class func createUser1() throws -> UserFactory {
        let user1path = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "user1"
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
        return try UserFactory(userDidOpt, appInstanceDidOpt, RELEASE_PROVIDER, MAIN_RESOLVER_URL, userDid1, user1path)
    }

    //develope 环境
    class func createUser2() throws -> UserFactory {
        let user2Path = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "user2"
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

        return try UserFactory(userDidOpt, appInstanceDidOpt, DEVELOP_PROVIDER, TEST_RESOLVER_URL, userDid2, user2Path)
    }
    
    //node 环境
    class func createUser3() throws -> UserFactory {
        let user3Path = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "user3"
        let userDidOpt = Options()
        userDidOpt.name = userDid3_name
        userDidOpt.mnemonic = userDid3_mn
        userDidOpt.phrasepass = userDid3_phrasepass
        userDidOpt.storepass = userDid3_storepass

        let appInstanceDidOpt = Options()
        appInstanceDidOpt.name = appInstance3_name
        appInstanceDidOpt.mnemonic = appInstance3_mn
        appInstanceDidOpt.phrasepass = appInstance3_phrasepass
        appInstanceDidOpt.storepass = appInstance3_storepass

        return try UserFactory(userDidOpt, appInstanceDidOpt, LOCAL_PROVIDER, MAIN_RESOLVER_URL, userDid3, user3Path)
    }
}

