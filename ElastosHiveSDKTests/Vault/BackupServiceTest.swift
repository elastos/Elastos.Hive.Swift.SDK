import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

import XCTest

class BackupServiceTest: XCTestCase {
    private var backupService: BackupProtocol?
    
    func test01CheckResult() {
        let lock = XCTestExpectation(description: "wait for check result.")
        do {
            try self.backupService?.checkResult().done({ _ in
                
            }).catch({[self] error in
                testCaseFailAndThrowError(error, lock)
            })
        } catch {
            testCaseFailAndThrowError(error, lock)
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test02StartBackup() {
        let lock = XCTestExpectation(description: "wait for start backup.")
        do {
            try self.backupService?.startBackup().done({ _ in
                
            }).catch({[self] error in
                testCaseFailAndThrowError(error, lock)
            })
        } catch {
            testCaseFailAndThrowError(error, lock)
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test03RestoreFrom() {
        let lock = XCTestExpectation(description: "wait for restore form.")
        do {
            try self.backupService?.restoreFrom().done({ _ in
                
            }).catch({[self] error in
                testCaseFailAndThrowError(error, lock)
            })
        } catch {
            testCaseFailAndThrowError(error, lock)
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    override func setUpWithError() throws {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = TestData.shared.getVault().done { (vault) in
            self.backupService = vault.backupService
            _ = try vault.connectionManager.headers()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
}
