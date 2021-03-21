
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class VaultSubscriptionTest: XCTestCase {
    private var subscription: VaultSubscription?
    private var hiveAPI: HiveAPI?
    
    func testSubscribe() throws {
        do {
            try subscription?.subscribe("free").done({ (vaultInfo) in
            })
        } catch {
            XCTFail()
            print(error)
        }
    }
    
    func testUnsubscribe() throws {
        do {
            try subscription?.unsubscribe().done({ _ in
                
            })
        } catch {
            XCTFail()
            print(error)
        }
    }
    
    func testActivate() throws {
        do {
            try subscription?.activate().done({ _ in
                
            })
        } catch {
            XCTFail()
            print(error)
        }
    }
    
    func testDeactivate() throws {
        do {
            try subscription?.deactivate().done({ _ in
            })
        } catch {
            XCTFail()
            print(error)
        }
    }

    override func setUpWithError() throws {
        let testData: TestData = TestData.shared()
        self.subscription = VaultSubscription(testData.appContext!, testData.ownerDid!, testData.providerAddress!, HiveAPI("", ""))
    }
}
