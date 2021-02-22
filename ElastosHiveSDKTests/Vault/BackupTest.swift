
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

public class UserBackupAuthenticationHandler: BackupAuthenticationHandler {
    public func targetHost() -> String {
        return "https://hive-testnet2.trinity-tech.io"
    }
    
    public func targetDid() -> String {
        return "did:elastos:iiTvjocqh7C78KjWyDVk2C2kbueJvkuXTW"
    }
    
    private var presentationInJWT: PresentationInJWT

    init(_ presentationInJWT: PresentationInJWT) {
        self.presentationInJWT = presentationInJWT
    }
    
    public func authorization(_ serviceDid: String) -> Promise<String> {
        return Promise<String> { resolver in
            resolver.fulfill(try presentationInJWT.getBackupVc(serviceDid))
        }
    }
}

public var factory: AppInstanceFactory?
class BackupTest: XCTestCase {
    private var client: HiveClientHandle?
    private var backup: Backup?
    private var manager: Management?
    
    func testGetState() {
        let lock = XCTestExpectation(description: "wait for test.")
        backup?.state().done({ stste in
            print(stste)
            lock.fulfill()
        }).catch({ error in
            XCTFail()
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func testSave() {
        let lock = XCTestExpectation(description: "wait for test.")
        let userBackupAuthenticationHandler = UserBackupAuthenticationHandler(user!.presentationInJWT)
        backup?.save(userBackupAuthenticationHandler).done({ stste in
            print(stste)
            lock.fulfill()
        }).catch({ error in
            XCTFail()
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testRestore() {
        let lock = XCTestExpectation(description: "wait for test.")
        let userBackupAuthenticationHandler = UserBackupAuthenticationHandler(user!.presentationInJWT)
        backup?.restore(userBackupAuthenticationHandler).done({ stste in
            print(stste)
            lock.fulfill()
        }).catch({ error in
            XCTFail()
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
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
