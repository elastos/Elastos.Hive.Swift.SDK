
import Foundation
import ElastosDIDSDK
import PromiseKit
import ElastosHiveSDK

public class CallerAppContextProvider: AppContextProvider {
    public var userDid: DIDApp
    public var appInstanceDid: DApp
    private var localDataDir: String

    public func getLocalDataDir() -> String? {
        self.localDataDir
    }
    
    public func getAppInstanceDocument() -> DIDDocument? {
        return try! appInstanceDid.getDocument()
    }
    
    public func getAuthorization(_ jwtToken: String) -> String? {
        return signAuthorization(jwtToken)
    }
    
    init(_ path: String, _ didapp:DIDApp, _ dapp: DApp) {
        self.localDataDir = path
        self.userDid = didapp
        self.appInstanceDid = dapp
    }
    
    public func signAuthorization(_ jwtToken: String) -> String? {
        
        var accessToken: String?
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async { [self] in
            do {
                let claims = try JwtParserBuilder().build().parseClaimsJwt(jwtToken).claims
                let iss = claims.getIssuer()
                let nonce = claims.get(key: "nonce") as? String
                
                let vc = try userDid.issueDiplomaFor(appInstanceDid)
                let vp: VerifiablePresentation = try appInstanceDid.createPresentation(vc, iss!, nonce!)
                let token = try appInstanceDid.createToken(vp, iss!)
                accessToken = token
                semaphore.signal()
            } catch{
                print(error)
                semaphore.signal()
            }
        }
        semaphore.wait()
        return accessToken!
    }
}

/*
public class UserVaultAuthHelper: NSObject {
    let presentationInJWT: PresentationInJWT
    let localDataDir: String
    
    public static func createInstance(_ userMnemonic: String, _ appMnemonic: String, _ localDataDir: String) throws -> UserVaultAuthHelper {
        return try UserVaultAuthHelper(userMnemonic, appMnemonic, localDataDir)
    }
    
    public init(_ userMnemonic: String, _ appMnemonic: String, _ localDataDir: String) throws {
        let userDidOpt = AppOptions()
        userDidOpt.mnemonic = userMnemonic
        userDidOpt.storepass = "storepass"

        let appInstanceDidOpt = AppOptions()
        appInstanceDidOpt.mnemonic = userMnemonic
        appInstanceDidOpt.storepass = "storepass"
        
       let backupOptions = BackupOptions()
        backupOptions.targetHost = "https://hive-testnet2.trinity-tech.io"
        backupOptions.targetDID = "did:elastos:iiTvjocqh7C78KjWyDVk2C2kbueJvkuXTW"
        
        presentationInJWT = try PresentationInJWT(userDidOpt, appInstanceDidOpt, backupOptions)
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

*/
