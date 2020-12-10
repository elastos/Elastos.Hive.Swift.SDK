
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class InstanceTest: XCTestCase {
    private var vault: Vault?
    private var database: DatabaseClient?
    private let collectionName = "works"

    func testGetVaultInstance() {
        do {
            try self.vault?.revokeAccessToken()
        } catch {
            XCTFail()
        }
    }
    
    func testAuth() {
        let lock = XCTestExpectation(description: "wait for test.")
        do {
            print("testAuth ========== star")
            try self.vault?.revokeAccessToken()
            let p1 = database?.createCollection(collectionName)
            let p2 = database?.createCollection(collectionName)
            let p3 = database?.createCollection(collectionName)

            let p4 = database?.createCollection(collectionName)

            let p5 = database?.createCollection(collectionName)

            let p6 = database?.createCollection(collectionName)
            
            when(resolved: p1!, p2!, p3!, p4!, p5!, p6!).done { re in
                XCTAssertTrue(true)
                lock.fulfill()
            }
            self.wait(for: [lock], timeout: 10000.0)
            
        } catch {
            XCTFail()
        }
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        do {
            Log.setLevel(.Debug)
            user = try UserFactory.createUser1()
            let lock = XCTestExpectation(description: "wait for test.")
            user?.client.createVault(user!.ownerDid, user?.provider).done { [self] vault in
                self.vault = vault
                self.database = (vault.database as! DatabaseClient)

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
    
}
