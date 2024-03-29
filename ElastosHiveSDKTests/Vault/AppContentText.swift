
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK
import AwaitKit

class AppContentText: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetProviderAddress() {
        XCTAssertNoThrow(try { [self] in
            try DIDBackend.initialize(DefaultDIDAdapter("https://api.elastos.io/eid"))
//            let providerAddress = try `await`(AppContext.getProviderAddress("did:elastos:ikkFHgoUHrVDTU8HTYDAWH9Z8S377Qvt7n"))
            // TODO:
            let providerAddress = try `await`(try TestData.shared().appContext.getProviderAddress())

            print("Provider address: \(providerAddress)")
            XCTAssertNotNil(providerAddress)
        }())
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
