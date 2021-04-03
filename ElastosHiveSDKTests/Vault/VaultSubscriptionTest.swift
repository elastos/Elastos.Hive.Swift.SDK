
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class VaultSubscriptionTest: XCTestCase {
    private var subscription: VaultSubscription?
    private var hiveAPI: HiveAPi?
    private var orderId = "5fbdf4ee46c829dc73a9a3d2"

    func testSubscribe() throws {
        let lock = XCTestExpectation(description: "wait for test.")
        try subscription?.subscribe("free").done({ (vaultInfo) in
            
        }).catch({[self] error in
            testCaseFailAndThrowError(error, lock)
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func testUnsubscribe() throws {
        let lock = XCTestExpectation(description: "wait for test unsubscribe.")
        try subscription?.unsubscribe().done({ _ in
            XCTAssertTrue(true)
            lock.fulfill()
        }).catch({[self] error in
            testCaseFailAndThrowError(error, lock)
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func testActivate() throws {
        let lock = XCTestExpectation(description: "wait for test activate.")
        try subscription?.activate().done({ _ in
            XCTAssertTrue(true)
            lock.fulfill()
        }).catch({[self] error in
            testCaseFailAndThrowError(error, lock)
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func testDeactivate() throws {
        let lock = XCTestExpectation(description: "wait for test deactivate.")
        try subscription?.deactivate().done({ _ in
            XCTAssertTrue(true)
            lock.fulfill()
        }).catch({[self] error in
            testCaseFailAndThrowError(error, lock)
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func testGetPricingPlanList() throws {
        let lock = XCTestExpectation(description: "wait for test deactivate.")
        subscription?.getPricingPlanList().done({ pricingPlanList in
            print(pricingPlanList)
            XCTAssertTrue(true)
            lock.fulfill()
        }).catch({[self] error in
            testCaseFailAndThrowError(error, lock)
        })
        self.wait(for: [lock], timeout: 1000.0)
    }

//    func testGetPricingPlan() {
//        let lock = XCTestExpectation(description: "wait for test deactivate.")
//        subscription?.getPricingPlan("free").done({ pricingPlan in
//            print(pricingPlan)
//            XCTAssertTrue(true)
//            lock.fulfill()
//        }).catch({[self] error in
//            testCaseFailAndThrowError(error, lock)
//        })
//        self.wait(for: [lock], timeout: 1000.0)
//    }
    
//    func testGetOrder() throws {
//        let lock = XCTestExpectation(description: "test for get order.")
//        self.subscription!.getOrder(orderId).done({ order in
//            XCTAssertTrue(true)
//            lock.fulfill()
//        }).catch {[self] error in
//            testCaseFailAndThrowError(error, lock)
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
        
    func testPayOrder() throws {
        
    }
    
    func testGetReceipt() throws {
//        let lock = XCTestExpectation(description: "test for get order.")
//        self.subscription!.getReceipt(<#T##receiptId: String##String#>)(orderId).done({ order in
//            XCTAssertTrue(true)
//            lock.fulfill()
//
//        }).catch {[self] error in
//            testCaseFailAndThrowError(error, lock)
//        }
//        self.wait(for: [lock], timeout: 1000.0)
    }

    override func setUpWithError() throws {
        let testData: TestData = TestData.shared
        self.subscription = VaultSubscription(testData.appContext!, testData.ownerDid!, testData.providerAddress!)
        _ = try self.subscription?.context.connectionManager.headers()
    }
}
