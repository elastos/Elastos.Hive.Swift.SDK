
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class InstanceTest: XCTestCase {
    private var vault: Vault?
    private var database: DatabaseClient?
    private let collectionName = "works"

    func test_GetVaultInstance() {
        do {
            try self.vault?.revokeAccessToken()
        } catch {
            XCTFail()
        }
    }
    
    func test_Auth() {
        let lock = XCTestExpectation(description: "wait for test.")
        do {
            print("testAuth ========== star")
            try self.vault?.revokeAccessToken()
            let p1 = database?.createCollection(collectionName, options: nil)
            let p2 = database?.createCollection(collectionName, options: nil)
            let p3 = database?.createCollection(collectionName, options: nil)

            let p4 = database?.createCollection(collectionName, options: nil)

            let p5 = database?.createCollection(collectionName, options: nil)

            let p6 = database?.createCollection(collectionName, options: nil)
            let p7 = database?.createCollection(collectionName, options: nil)
            let p8 = database?.createCollection(collectionName, options: nil)
            let p9 = database?.createCollection(collectionName, options: nil)
            
            
            when(resolved: p1!, p2!, p3!, p4!, p5!, p6!, p7!, p8!, p9!).done { re in
                XCTAssertTrue(true)
                lock.fulfill()
            }
            self.wait(for: [lock], timeout: 10000.0)
            
        } catch {
            XCTFail()
        }
    }
    
    func test_getVault() {
        let lock = XCTestExpectation(description: "wait for test.")
        user?.client.getVault(user!.userFactoryOpt.ownerDid, user?.userFactoryOpt.provider).done{ vault in
            XCTAssertNotNil(vault)
            lock.fulfill()
        }.catch{ e in
            XCTFail()
            lock.fulfill()
        }

        self.wait(for: [lock], timeout: 10000.0)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        do {
            Log.setLevel(.Debug)
            user = try AppInstanceFactory.createUser1()
            let lock = XCTestExpectation(description: "wait for test.")
            user!.client.getVault(user!.userFactoryOpt.ownerDid, user?.userFactoryOpt.provider).done { [self] vault in
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
