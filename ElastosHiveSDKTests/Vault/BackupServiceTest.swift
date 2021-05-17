/*
* Copyright (c) 2020 Elastos Foundation
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

import XCTest

class BackupServiceTest: XCTestCase {
    private var backupService: BackupProtocol?
    
    func test01CheckResult() {
        let lock = XCTestExpectation(description: "wait for check result.")
        self.backupService!.checkResult().done({ result in
            XCTAssertTrue(true, "check result test case passed")
            lock.fulfill()
        }).catch({ error in
            XCTFail("\(error)")
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test02StartBackup() {
        let lock = XCTestExpectation(description: "wait for start backup.")
        self.backupService!.startBackup().done({ _ in
            XCTAssertTrue(true, "start backup test case passed")
            lock.fulfill()
        }).catch({ error in
            XCTFail("\(error)")
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test03StopBackup() {
        // TODO
    }
    
    func test04RestoreFrom() {
        let lock = XCTestExpectation(description: "wait for restore form.")
        self.backupService!.restoreFrom().done({ _ in
            XCTAssertTrue(true, "restore formp test case passed")
            lock.fulfill()
        }).catch({ error in
            XCTFail("\(error)")
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test05StopRestore() {
        // TODO
    }
    
    override func setUpWithError() throws {
        Log.setLevel(.Debug)
        self.backupService = try TestData.shared.backupService()
    }
}
