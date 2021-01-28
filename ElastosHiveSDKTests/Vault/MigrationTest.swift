
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class MigrationTest: XCTestCase {
    private var backup: Backup?
    private var manager: Management?
    
    func testMigration() {
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



/*
 public class MigrationTest {
     @Test
     public void testMigration() {
         CompletableFuture<Booleasn> future = managerApi.freezeVault()
                 .thenComposeAsync(aBoolean -> {
                     BackupAuthenticationHandler handler = new BackupAuthenticationHandler() {
                         @Override
                         public CompletableFuture<String> getAuthorization(String serviceDid) {
                             return CompletableFuture.supplyAsync(() ->
                                     factory.getBackupVc(serviceDid));
                         }

                         @Override
                         public String getTargetHost() {
                             return factory.getTargetHost();
                         }

                         @Override
                         public String getTargetDid() {
                             return factory.getTargetDid();
                         }
                     };
                     return backupApi.save(handler);
                 }).thenApplyAsync(aBoolean -> {
                     for (; ; ) {
                         try {
                             Thread.sleep(10 * 1000);
                         } catch (InterruptedException e) {
                             e.printStackTrace();
                         }
                         State state = backupApi.getState().join();
                         if (state == State.STOP) {
                             return true;
                         }
                     }
                 }).thenComposeAsync(aBoolean -> backupApi.active())
                 .handleAsync((aBoolean, throwable) -> {
                     if (null != throwable) {
                         throwable.printStackTrace();
                     }
                     return (aBoolean && (null == throwable));
                 });


         try {
             assertTrue(future.get());
             assertTrue(future.isCompletedExceptionally() == false);
             assertTrue(future.isDone());
         } catch (Exception e) {
             e.printStackTrace();
             fail();
         }
     }


     private static AppInstanceFactory factory;
     static Backup backupApi;
     private static Manager managerApi;

     @BeforeClass
     public static void setUp() {
         factory = AppInstanceFactory.configSelector();
         managerApi = factory.getManager();
         backupApi = factory.getBackup();
     }
 }
 */
