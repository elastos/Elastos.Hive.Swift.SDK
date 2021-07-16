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
import AwaitKit

import XCTest

class BackupServiceTest: XCTestCase {
    private var _backupService: BackupService?
    
    override func setUpWithError() throws {
        XCTAssertNoThrow({ [self] in
            let testData = TestData.shared()
            _backupService = try testData.backupService()
        })
    }
    
    func test01StartBackup() {
        XCTAssertNoThrow({ [self] in
            try await(_backupService!.startBackup())
        })
    }

    func test02CheckResult() {
        XCTAssertNoThrow({ [self] in
            XCTAssertNotNil(try await(_backupService!.checkResult()))
        })
    }
    
    func test03StopBackup() {
        // TODO
    }
    
    func test04RestoreFrom() {
        XCTAssertNoThrow({ [self] in
            try await(_backupService!.restoreFrom())
        })
    }
    
    func testStopRestore() {
        // TODO
    }
}

