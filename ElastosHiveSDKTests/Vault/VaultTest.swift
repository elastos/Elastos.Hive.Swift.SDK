import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class VaultTest: XCTestCase {
    private var vault: Vault?
    
    override func setUpWithError() throws {
        self.vault = TestData.shared.newVault()
    }
    
    func testGetFiles() throws {
    
    }
    
    func testGetMongoDb() throws {
    
    }

    func testGetProviderAddress() throws {
    
    }
    
    func testGetOwnerDid() throws {
    
    }
    
    func testGetVersion() {
        let lock = XCTestExpectation(description: "wait for get node version.")
        self.vault?.getVersion().done({ version in
            XCTAssert(version.count > 0)
            lock.fulfill()
        }).catch { error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func testGetCommitHash() {
        let lock = XCTestExpectation(description: "wait for get node version.")
        self.vault?.getCommitHash().done({ hash in
            XCTAssert(hash.count > 0)
            lock.fulfill()
        }).catch { error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
}
