

import Foundation
import ElastosDIDSDK
import PromiseKit
//import ElastosHiveSDK

public class UserHiveContext: ApplicationContext {
    private var localDataDir: String
    private var presentationInJWT: PresentationInJWT
    
    init(_ localDataDir: String, _ pjwt: PresentationInJWT) {
        self.localDataDir = localDataDir
        self.presentationInJWT = pjwt
    }
    
    public func getLocalDataDir() -> String {
        return self.localDataDir
    }
    
    public func getAppInstanceDocument() -> DIDDocument {
        return self.presentationInJWT.doc!
    }
    
    public func getAuthorization(_ jwtToken: String) -> Promise<String> {
        return self.presentationInJWT.getAuthToken(jwtToken)
    }
}

public class UserVaultAuthHelper: NSObject {
    let presentationInJWT: PresentationInJWT
    let localDataDir: String
    
    public static func createInstance(_ userMnemonic: String, _ appMnemonic: String, _ localDataDir: String) throws -> UserVaultAuthHelper {
        return try UserVaultAuthHelper(userMnemonic, appMnemonic, localDataDir)
    }
    
    public init(_ userMnemonic: String, _ appMnemonic: String, _ localDataDir: String) throws {
        let userDidOpt = PresentationInJWTOptions()
        userDidOpt.mnemonic = userMnemonic
        userDidOpt.storepass = "storepass"

        let appInstanceDidOpt = PresentationInJWTOptions()
        appInstanceDidOpt.mnemonic = userMnemonic
        appInstanceDidOpt.storepass = "storepass"
        
        presentationInJWT = try PresentationInJWT(userDidOpt, appInstanceDidOpt)
        self.localDataDir = localDataDir
    }
    
    public static func generateMnemonic(_ language: String) throws -> String {
        return try Mnemonic.generate(language)
    }
    
    public func getClientWithAuth() -> Promise<HiveClientHandle> {
        return Promise { resolver in
            let client = try HiveClientHandle.createInstance(withContext: UserHiveContext(localDataDir, presentationInJWT))
            resolver.fulfill(client)
        }
    }
    
    public func generateAuthPresentationJWT(_ challengeJwtToken: String) -> Promise<String> {
        return presentationInJWT.getAuthToken(challengeJwtToken)
    }
    
    public var appDIDDocument: DIDDocument? {
        return presentationInJWT.doc
    }
}

