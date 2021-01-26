
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class ManagerTest: XCTestCase {
    private var manager: Manager?
    
    func testCreateVault() {
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
    
    func testCreateBackup() {
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
    
//    func testDestroyVault() {
//        let lock = XCTestExpectation(description: "wait for test.")
//        manager?.destroyVault().done({ success in
//            print(success)
//            lock.fulfill()
//        }).catch({ error in
//            XCTFail()
//            lock.fulfill()
//        })
//        self.wait(for: [lock], timeout: 1000.0)
//    }
    
//    func testFreezeVault() {
//        let lock = XCTestExpectation(description: "wait for test.")
//        manager?.freezeVault().done({ success in
//            print(success)
//            lock.fulfill()
//        }).catch({ error in
//            XCTFail()
//            lock.fulfill()
//        })
//        self.wait(for: [lock], timeout: 1000.0)
//    }
    /*
     @Test
     public void testFreezeVault() {
         CompletableFuture<Boolean> future = managerApi.freezeVault()
                 .handle((vault, throwable) -> (null == throwable));

         try {
             assertTrue(future.get());
             assertTrue(future.isCompletedExceptionally() == false);
             assertTrue(future.isDone());
         } catch (Exception e) {
             e.printStackTrace();
             fail();
         }
     }
     
     @Test
     public void testDestroyVault() {
         CompletableFuture<Boolean> future = managerApi.destroyVault()
                 .handle((vault, throwable) -> (null == throwable));

         try {
             assertTrue(future.get());
             assertTrue(future.isCompletedExceptionally() == false);
             assertTrue(future.isDone());
         } catch (Exception e) {
             e.printStackTrace();
             fail();
         }
     }
     */
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        do {
            Log.setLevel(.Debug)
            user = try AppInstanceFactory.createUser1()
            let lock = XCTestExpectation(description: "wait for test.")
            user?.client.getManager(user!.userFactoryOpt.ownerDid, user?.userFactoryOpt.provider).done{ manager in

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
