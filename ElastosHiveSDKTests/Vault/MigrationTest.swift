
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class MigrationTest: XCTestCase {
    private var backup: Backup?
    private var manager: Management?
    
    func testMigration() {
        let lock = XCTestExpectation(description: "wait for test.")
        let userBackupAuthenticationHandler = UserBackupAuthenticationHandler(user!.presentationInJWT)
        manager?.freezeVault().then({ [self] success -> Promise<Bool> in
            return backup!.save(userBackupAuthenticationHandler)
        }).then({ [self] success -> Promise<Backup> in
            var loop = true
            while loop {
                Thread.sleep(forTimeInterval: 5.00)
                self.backup!.state().done({ st in
                    print(st)
                    if st.rawValue == "stop" {
                        loop = false
                    }
                }).catch({ error in
                    XCTFail()
                    lock.fulfill()
                })
            }
            return user!.client.getBackup(user!.targetDid, user!.targetHost)
        }).then({ [self] backup -> Promise<Bool> in
            return manager!.createVault().then({ vault -> Promise<Bool> in
                return backup.active()
            })
//            return backup.active()
        }).done({ success in
            print(success)
            XCTAssertTrue(success)
            lock.fulfill()
        }).catch({ error in
            XCTFail()
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000000.0)
    }

    override func setUpWithError() throws {
        do {
            Log.setLevel(.Debug)
            user = try AppInstanceFactory.createUser2()
            let lock = XCTestExpectation(description: "wait for test.")
            
            user!.client.getManager(user!.userFactoryOpt.ownerDid, user?.userFactoryOpt.provider).then { manager -> Promise<Backup> in
                self.manager = manager
                return manager.createBackup()
            }.then { backup -> Promise<Backup> in
                return user!.client.getBackup(user!.userFactoryOpt.ownerDid, user?.userFactoryOpt.provider)
            }.done { [self] backup in
                self.backup = (backup )
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

