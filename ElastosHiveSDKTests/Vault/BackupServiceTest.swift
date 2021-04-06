import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

import XCTest

class BackupServiceTest: XCTestCase {
    private var backupService: BackupProtocol?
    
    func testCheckResult() {
        let lock = XCTestExpectation(description: "wait for check result.")
        self.backupService!.checkResult().done({ result in
            XCTAssert(true)
            lock.fulfill()
        }).catch({[self] error in
            testCaseFailAndThrowError(error, lock)
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func testStartBackup() {
        let lock = XCTestExpectation(description: "wait for start backup.")
        self.backupService!.startBackup().done({ _ in
            XCTAssert(true)
            lock.fulfill()
        }).catch({[self] error in
            testCaseFailAndThrowError(error, lock)
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func testRestoreFrom() {
        let lock = XCTestExpectation(description: "wait for restore form.")
        self.backupService!.restoreFrom().done({ _ in
            XCTAssert(true)
            lock.fulfill()
        }).catch({[self] error in
            testCaseFailAndThrowError(error, lock)
        })
        self.wait(for: [lock], timeout: 1000.0)
    }

    override func setUpWithError() throws {
        self.backupService = try TestData.shared.backupService()
    }
}
