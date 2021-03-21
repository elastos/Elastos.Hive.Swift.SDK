
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

/*
class ManagerTest: XCTestCase {
    private var manager: Management?
    
    func test_0_CreateVault() {
        let lock = XCTestExpectation(description: "wait for test.")
        manager?.createVault().done({ success in
            print(success)
            lock.fulfill()
        }).catch({ error in
            XCTFail()
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test_1_CreateBackup() {
        let lock = XCTestExpectation(description: "wait for test.")
        manager?.createBackup().done({ success in
            print(success)
            lock.fulfill()
        }).catch({ error in
            XCTFail()
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test_2_VaultServiceInfo() {
        let lock = XCTestExpectation(description: "wait for test.")
        manager?.vaultServiceInfo().done({ success in
            print(success)
            lock.fulfill()
        }).catch({ error in
            XCTFail()
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test_3_BackupServiceInfo() {
        let lock = XCTestExpectation(description: "wait for test.")
        manager?.backupServiceInfo().done({ success in
            print(success)
            lock.fulfill()
        }).catch({ error in
            XCTFail()
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    func test_4_DestroyVault() {
        let lock = XCTestExpectation(description: "wait for test.")
        manager?.destroyVault().done({ success in
            print(success)
            lock.fulfill()
        }).catch({ error in
            XCTFail()
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test_5_FreezeVault() {
        let lock = XCTestExpectation(description: "wait for test.")
        manager?.freezeVault().done({ success in
            print(success)
            lock.fulfill()
        }).catch({ error in
            XCTFail()
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test_6_UnfreezeVault() {
        let lock = XCTestExpectation(description: "wait for test.")
        manager?.unfreezeVault().done({ success in
            print(success)
            lock.fulfill()
        }).catch({ error in
            XCTFail()
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        do {
            Log.setLevel(.Debug)
            user = try AppInstanceFactory.createUser2()
            let lock = XCTestExpectation(description: "wait for test.")
            user?.client.getManager(user!.userFactoryOpt.ownerDid, user!.userFactoryOpt.provider, user!.backupOptions.targetHost).done{ manager in

                self.manager = manager
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
*/
