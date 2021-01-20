
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

public var user: AppInstanceFactory?
class BackupTest: XCTestCase {
    private var client: HiveClientHandle?
    private var backup: Backup?

    func testGetState() {
        do {
            
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    override func setUpWithError() {
        do {
            Log.setLevel(.Debug)
            user = try AppInstanceFactory.createUser1()
            let lock = XCTestExpectation(description: "wait for test.")
            user!.client.getVault(user!.userFactoryOpt.ownerDid, user?.userFactoryOpt.provider).done { [self] vault in
                self.backup = (vault as! Backup)
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
