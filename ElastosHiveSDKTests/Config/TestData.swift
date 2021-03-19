import Foundation
@testable import ElastosHiveSDK
import ElastosDIDSDK

public class TestData {
    public static var testData: TestData {
        return TestData(nil, nil, nil, nil)
    }
    
    public init (_ userDid: DIDApp?, _ nodeConfig: NodeConfig?, _ appContext: AppContext?, _ providerAddress: String?) {
        self.userDid = userDid
        self.nodeConfig = nodeConfig
        self.appContext = appContext
        self.providerAddress = providerAddress
    }

    public var userDid: DIDApp?
    public var appInstanceDid: DApp?
    public var nodeConfig: NodeConfig?
    public var appContext: AppContext?
    public var providerAddress: String? {
        set {
            self.nodeConfig?.provider = newValue
        }
        get {
            return self.nodeConfig?.provider
        }
    }
    
    public var ownerDid: String? {
        get {
            return self.nodeConfig?.ownerDid
        }
    }
    
    class func shared() -> TestData {
        return testData
    }
    
    public func newVault() -> Vault {
        return Vault(appContext!, nodeConfig!.ownerDid!, nodeConfig!.provider!)
    }
    /*
     
     public Vault newVault() {
         return new Vault(context, nodeConfig.ownerDid(), nodeConfig.provider());
     }
     */
}
