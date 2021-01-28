
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class UserContext: ApplicationContext {
    private var option: ClientOptions
    private var presentationInJWT: PresentationInJWT
    private var vault: Vault?
    private var backup: Backup?
    private var manager: Management?
    
    init(_ option: ClientOptions, _ pjwt: PresentationInJWT) {
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
    var userFactoryOpt: ClientOptions

    init(_ userDidOpt: AppOptions,
         _ appInstanceDidOpt: AppOptions,
         _ backupOptions: BackupOptions,
         _ userFactoryOpt: ClientOptions) throws {
        self.userFactoryOpt = userFactoryOpt

        presentationInJWT = try PresentationInJWT(userDidOpt, appInstanceDidOpt, backupOptions)
        if !resolverDidSetup {
            try HiveClientHandle.setupResolver(userFactoryOpt.resolveUrl, AppInstanceFactory.didCachePath)
            resolverDidSetup = true
        }
        let contenxt = UserContext(userFactoryOpt, presentationInJWT)
        client = try HiveClientHandle.createInstance(withContext: contenxt)
    }
    
    class func createFactory(_ userDidOpt: AppOptions,
                             _ appInstanceDidOpt: AppOptions,
                             _ backupOptions: BackupOptions,
                             _ userFactoryOpt: ClientOptions) throws -> AppInstanceFactory {
        return try AppInstanceFactory(userDidOpt, appInstanceDidOpt, backupOptions, userFactoryOpt)
    }
    
    //release环境（MainNet + https://hive1.trinity-tech.io + userDid1）
    class func createUser1() throws -> AppInstanceFactory {
        let user1path = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "user1"
        let userDidOpt = AppOptions()
        userDidOpt.name = userDid1_name
        userDidOpt.mnemonic = userDid1_mn
        userDidOpt.phrasepass = userDid1_phrasepass
        userDidOpt.storepass = userDid1_storepass

        let appInstanceDidOpt = AppOptions()
        appInstanceDidOpt.name = appInstance1_name
        appInstanceDidOpt.mnemonic = appInstance1_mn
        appInstanceDidOpt.phrasepass = appInstance1_phrasepass
        appInstanceDidOpt.storepass = appInstance1_storepass
        
        let userFactoryOpt = ClientOptions()
        userFactoryOpt.provider = RELEASE_PROVIDER
        userFactoryOpt.resolveUrl = MAIN_RESOLVER_URL
        userFactoryOpt.ownerDid = userDid1
        userFactoryOpt.storePath = user1path
        
        let backupOptions = BackupOptions()
        backupOptions.targetHost = "https://hive1.trinity-tech.io"
        backupOptions.targetDID = "did:elastos:ijYUBb36yCXU6yzhydnkCCAXh7ZRW4X85J"
        return try AppInstanceFactory(userDidOpt, appInstanceDidOpt, backupOptions, userFactoryOpt)
    }

    //develope 环境
    class func createUser2() throws -> AppInstanceFactory {
        let user2Path = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "user2"
        let userDidOpt = AppOptions()
        userDidOpt.name = userDid2_name
        userDidOpt.mnemonic = userDid2_mn
        userDidOpt.phrasepass = userDid2_phrasepass
        userDidOpt.storepass = userDid2_storepass

        let appInstanceDidOpt = AppOptions()
        appInstanceDidOpt.name = appInstance2_name
        appInstanceDidOpt.mnemonic = appInstance2_mn
        appInstanceDidOpt.phrasepass = appInstance2_phrasepass
        appInstanceDidOpt.storepass = appInstance2_storepass
        
        let userFactoryOpt = ClientOptions()
        userFactoryOpt.provider = DEVELOP_TEST_PROVIDER
        userFactoryOpt.resolveUrl = TEST_RESOLVER_URL
        userFactoryOpt.ownerDid = userDid2
        userFactoryOpt.storePath = user2Path
        
        let backupOptions = BackupOptions()
        backupOptions.targetHost = "https://hive-testnet2.trinity-tech.io"
        backupOptions.targetDID = "did:elastos:iiTvjocqh7C78KjWyDVk2C2kbueJvkuXTW"
        
        return try AppInstanceFactory(userDidOpt, appInstanceDidOpt, backupOptions, userFactoryOpt)
    }
    
    //node 环境
    class func createUser3() throws -> AppInstanceFactory {
        let user3Path = "\(NSHomeDirectory())/Library/Caches/store" + "/" + "user3"
        let userDidOpt = AppOptions()
        userDidOpt.name = userDid3_name
        userDidOpt.mnemonic = userDid3_mn
        userDidOpt.phrasepass = userDid3_phrasepass
        userDidOpt.storepass = userDid3_storepass

        let appInstanceDidOpt = AppOptions()
        appInstanceDidOpt.name = appInstance3_name
        appInstanceDidOpt.mnemonic = appInstance3_mn
        appInstanceDidOpt.phrasepass = appInstance3_phrasepass
        appInstanceDidOpt.storepass = appInstance3_storepass

        let userFactoryOpt = ClientOptions()
        userFactoryOpt.provider = DEVELOP_TEST_PROVIDER
        userFactoryOpt.resolveUrl = MAIN_RESOLVER_URL
        userFactoryOpt.ownerDid = userDid3
        userFactoryOpt.storePath = user3Path
        
        let backupOptions = BackupOptions()
        backupOptions.targetHost = "https://hive1.trinity-tech.io"
        backupOptions.targetDID = "did:elastos:ijYUBb36yCXU6yzhydnkCCAXh7ZRW4X85J"
        
        return try AppInstanceFactory(userDidOpt, appInstanceDidOpt, backupOptions, userFactoryOpt)
    }
}

class ClientOptions {
    var storePath: String = ""
    var ownerDid: String = ""
    var resolveUrl: String = ""
    var provider: String = ""
}
