
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK
/*
class MigrationTest: XCTestCase {
    private var backup: Backup?
    private var manager: Management?
    private let collectionName = "migration_swift"
    private let fileRemotePath = "migration_swift/test.txt"
    private var vault: Vault?
    private var database: Database?
    
    func testMigration() {
        let lock = XCTestExpectation(description: "wait for test.")
        let userBackupAuthenticationHandler = UserBackupAuthenticationHandler(user!.presentationInJWT)
        manager?.createVault().then({ [self] vault -> Promise<Bool> in
            self.vault = vault
            return manager!.unfreezeVault()
        }).then({ [self] success -> Promise<Bool> in
            return self.vault!.database.createCollection(collectionName, options: nil)
        }).then({ [self] sucess -> Promise<InsertOneResult> in
            let dic = ["author": "john doe1", "title": "Eve for Dummies1"]
            let insertOptions = InsertOptions()
            insertOptions.bypassDocumentValidation(false).ordered(true)
            return self.vault!.database.insertOne(collectionName, dic, options: insertOptions)
        }).then({ [self] result -> Promise<FileWriter> in
            return self.vault!.files.upload(fileRemotePath)
        }).then({ writer -> Promise<Bool> in
            try writer.write(data: "migration test txt".data(using: .utf8)!, { err in
                print(err)
            })

            writer.close { (success, error) in
                print(success)
            }
            Thread.sleep(forTimeInterval: 5.0)
            return Promise.value(true) // 模拟成功
        })
            .then({ [self] vault -> Promise<Bool> in
            return manager!.freezeVault()
        }).then({ [self] vault -> Promise<Bool> in
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
            return user!.client.getBackup(user!.targetDid, user!.targetHost, user!.backupOptions.targetHost)
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
            
            user!.client.getManager(user!.userFactoryOpt.ownerDid, user!.userFactoryOpt.provider, user!.backupOptions.targetHost).then { manager -> Promise<Backup> in
                self.manager = manager
                return manager.createBackup()
            }.then { backup -> Promise<Backup> in
                return user!.client.getBackup(user!.userFactoryOpt.ownerDid, user!.userFactoryOpt.provider, user!.backupOptions.targetHost)
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

*/
