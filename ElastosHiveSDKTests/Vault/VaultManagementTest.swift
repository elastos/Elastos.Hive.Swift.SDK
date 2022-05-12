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

// Disabled
class VaultManagementTest: XCTestCase {
    private var _vault: Vault?

    override func setUp() {
        Log.setLevel(.Debug)
        XCTAssertNoThrow(try { [self] in
            let testData = TestData.shared()
            _vault = try testData.newVault()
        }())
    }
    
    override func tearDown() {
        
    }

    func testGetFiles() throws {
        
    }
    
    func testGetMongoDb() throws {
        
    }
    
    func testGetProviderAddress() throws {
        
    }
    
    func testGetOwnerDid() throws {
        
    }
    
    func testGetVersion() {
        XCTAssertNoThrow(try { [self] in
            XCTAssertNotNil(try `await`(_vault!.getNodeVersion()))
        }())
    }
    
    func testGetCommitHash() {
        XCTAssertNoThrow(try { [self] in
            XCTAssertNotNil(try `await`(_vault!.getLatestCommitId()))
        }())
    }
    
    
    func testGetNodeInfo() {
        XCTAssertNoThrow(try { [self] in
            let info = try `await`(_vault!.getNodeInfo())
            
            XCTAssertNotNil(info)
            XCTAssertNotNil(info.name)
            XCTAssertNotNil(info.developerDid)
            XCTAssertNotNil(info.iconUrl)
            XCTAssertNotNil(info.userDid)
            XCTAssertNotNil(info.appDid)
            XCTAssertTrue(info.usedStorageSize > 0)
        }())
    }
}
