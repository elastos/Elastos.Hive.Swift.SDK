
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class VersionTest: XCTestCase {
    private var vault: Vault?
    
    func test_getVersion() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = vault?.nodeVersion().done{ version in
            print(version)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test_getLastCommitId() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = vault?.nodeLastCommitId().done{ commitId in
            print(commitId)
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
            Log.setLevel(.Debug)
            user = try UserFactory.createUser1()
            let lock = XCTestExpectation(description: "wait for test.")
            user?.client.getVault(user!.ownerDid, user?.provider).done{ vault in
                self.vault = vault
                lock.fulfill()
            }.catch{ error in
                print(error)
                lock.fulfill()
            }
            /*user?.client.createVault(user!.ownerDid, user?.provider).done{ vault in
                self.vault = vault
                lock.fulfill()
            }.catch { error in
                print(error)
                lock.fulfill()
            }*/
            self.wait(for: [lock], timeout: 100.0)
        } catch {
            XCTFail()
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}
