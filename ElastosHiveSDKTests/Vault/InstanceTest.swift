
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class InstanceTest: XCTestCase {
    private var vault: Vault?

    func testGetVaultInstance() {
        let lock = XCTestExpectation(description: "wait for test.")
        do {
            user = try UserFactory.createUser1()
            _ = user?.client.getVault(user!.ownerDid, user?.provider).done { vault  in
                self.vault = vault
                lock.fulfill()
            }
            .catch{ error in
                XCTFail()
                lock.fulfill()
            }
            self.wait(for: [lock], timeout: 100.0)
            try self.vault?.revokeAccessToken()
        } catch {
            XCTFail()
        }
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
}
