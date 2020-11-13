
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

public class UserFactory {
    static let didCachePath = "didCache"
    var vault: Vault?
    var resolverDidSetup = false
    var presentationInJWT: PresentationInJWT?
    var client: HiveClientHandle

    init(_ userDidOpt: Options, _ appInstanceDidOpt: Options, _ tokenCachePath: String) throws {
        presentationInJWT = try PresentationInJWT(userDidOpt, appInstanceDidOpt)
        if !resolverDidSetup {
            try HiveClientHandle.setupResolver(RESOLVER_URL, UserFactory.didCachePath)
            resolverDidSetup = true
        }
        let options = HiveClientOptions()
        _ = options.setLocalDataPath(tokenCachePath)
        _ = options.setAuthenticator(VaultAuthenticator())
        _ = options.setAuthenticationDIDDocument((presentationInJWT?.doc)!)
        client = try HiveClientHandle.createInstance(withOptions: options)
    }

    class func createFactory(_ userDidOpt: Options, _ appInstanceDidOpt: Options, _ tokenCachePath: String) throws -> UserFactory {
        return try UserFactory(userDidOpt, appInstanceDidOpt, tokenCachePath)
    }

    class func createUser1() throws -> UserFactory {
        let user1 = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "user1"
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

        return try UserFactory(userDidOpt, appInstanceDidOpt, user1)
    }

    class func createUser2() throws -> UserFactory {
        let user2 = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "user2"
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

        return try UserFactory(userDidOpt, appInstanceDidOpt, user2)
    }
}
