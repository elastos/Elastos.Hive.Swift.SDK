
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class UserContext: ApplicationContext {
    private var option: UserOptions
    private var presentationInJWT: PresentationInJWT
    init(_ option: UserOptions, _ pjwt: PresentationInJWT) {
        self.option = option
        self.presentationInJWT = pjwt
    }
    func getLocalDataDir() -> String {
        return self.option.storePath
    }
    
    func getAppInstanceDocument() -> DIDDocument {
        return self.presentationInJWT.doc!
    }
    
    func getAuthorization(_ jwtToken: String) -> Promise<String> {
        return self.presentationInJWT.getAuthToken(jwtToken)
    }
}

public class AppInstanceFactory {
    static let didCachePath = "didCache"
    var vault: Vault?
    var resolverDidSetup = false
    var presentationInJWT: PresentationInJWT
    var client: HiveClientHandle
    var userFactoryOpt: UserOptions

    init(_ userDidOpt: PresentationInJWTOptions,
         _ appInstanceDidOpt: PresentationInJWTOptions,
         _ userFactoryOpt: UserOptions) throws {
        self.userFactoryOpt = userFactoryOpt

        presentationInJWT = try PresentationInJWT(userDidOpt, appInstanceDidOpt)
        if !resolverDidSetup {
            try HiveClientHandle.setupResolver(userFactoryOpt.resolveUrl, AppInstanceFactory.didCachePath)
            resolverDidSetup = true
        }
        let contenxt = UserContext(userFactoryOpt, presentationInJWT)
        client = try HiveClientHandle.createInstance(withContext: contenxt)
    }
    
    class func createFactory(_ userDidOpt: PresentationInJWTOptions,
                             _ appInstanceDidOpt: PresentationInJWTOptions,
                             _ userFactoryOpt: UserOptions) throws -> AppInstanceFactory {
        return try AppInstanceFactory(userDidOpt, appInstanceDidOpt, userFactoryOpt)
    }
    
    //release环境（MainNet + https://hive1.trinity-tech.io + userDid1）
    class func createUser1() throws -> AppInstanceFactory {
        let user1path = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "user1"
        let userDidOpt = PresentationInJWTOptions()
        userDidOpt.name = userDid1_name
        userDidOpt.mnemonic = userDid1_mn
        userDidOpt.phrasepass = userDid1_phrasepass
        userDidOpt.storepass = userDid1_storepass

        let appInstanceDidOpt = PresentationInJWTOptions()
        appInstanceDidOpt.name = appInstance1_name
        appInstanceDidOpt.mnemonic = appInstance1_mn
        appInstanceDidOpt.phrasepass = appInstance1_phrasepass
        appInstanceDidOpt.storepass = appInstance1_storepass
        
        let userFactoryOpt = UserOptions()
        userFactoryOpt.provider = RELEASE_PROVIDER
        userFactoryOpt.resolveUrl = MAIN_RESOLVER_URL
        userFactoryOpt.ownerDid = userDid1
        userFactoryOpt.storePath = user1path
        return try AppInstanceFactory(userDidOpt, appInstanceDidOpt, userFactoryOpt)
    }

    //develope 环境
    class func createUser2() throws -> AppInstanceFactory {
        let user2Path = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "user2"
        let userDidOpt = PresentationInJWTOptions()
        userDidOpt.name = userDid2_name
        userDidOpt.mnemonic = userDid2_mn
        userDidOpt.phrasepass = userDid2_phrasepass
        userDidOpt.storepass = userDid2_storepass

        let appInstanceDidOpt = PresentationInJWTOptions()
        appInstanceDidOpt.name = appInstance2_name
        appInstanceDidOpt.mnemonic = appInstance2_mn
        appInstanceDidOpt.phrasepass = appInstance2_phrasepass
        appInstanceDidOpt.storepass = appInstance2_storepass
        
        let userFactoryOpt = UserOptions()
        userFactoryOpt.provider = DEVELOP_PROVIDER
        userFactoryOpt.resolveUrl = TEST_RESOLVER_URL
        userFactoryOpt.ownerDid = userDid2
        userFactoryOpt.storePath = user2Path
        return try AppInstanceFactory(userDidOpt, appInstanceDidOpt, userFactoryOpt)
    }
    
    //node 环境
    class func createUser3() throws -> AppInstanceFactory {
        let user3Path = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "user3"
        let userDidOpt = PresentationInJWTOptions()
        userDidOpt.name = userDid3_name
        userDidOpt.mnemonic = userDid3_mn
        userDidOpt.phrasepass = userDid3_phrasepass
        userDidOpt.storepass = userDid3_storepass

        let appInstanceDidOpt = PresentationInJWTOptions()
        appInstanceDidOpt.name = appInstance3_name
        appInstanceDidOpt.mnemonic = appInstance3_mn
        appInstanceDidOpt.phrasepass = appInstance3_phrasepass
        appInstanceDidOpt.storepass = appInstance3_storepass

        let userFactoryOpt = UserOptions()
        userFactoryOpt.provider = LOCAL_PROVIDER
        userFactoryOpt.resolveUrl = MAIN_RESOLVER_URL
        userFactoryOpt.ownerDid = userDid3
        userFactoryOpt.storePath = user3Path
        return try AppInstanceFactory(userDidOpt, appInstanceDidOpt, userFactoryOpt)
    }
}

class UserOptions {
    var storePath: String = ""
    var ownerDid: String = ""
    var resolveUrl: String = ""
    var provider: String = ""
}
