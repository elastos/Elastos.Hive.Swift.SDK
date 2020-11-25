
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class PaymentTest: XCTestCase {
    private var payment: Payment?
    
    private let planName = "Free"
    private let priceName = "Rookie"
    private let orderId = "5fb5f1be9284ff39688ea77e"

    func test0_GetPaymentInfo() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = payment?.getPaymentInfo().done{ info in
            print(info)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test2_getPricingPlan() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = payment?.getPricingPlan(planName).done{ plan in
            print(plan)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test2_getPaymentVersion() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = payment?.getPaymentVersion().done{ version in
            print(version)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        do {
            user = try UserFactory.createUser1()
            let lock = XCTestExpectation(description: "wait for test.")
            user?.client.createVault(OWNERDID, user?.provider).done{ vault in

                self.payment = (vault.payment)
                lock.fulfill()
            }.catch { error in
                print(error)
                lock.fulfill()
            }
            self.wait(for: [lock], timeout: 100.0)
        } catch {
            XCTFail()
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
