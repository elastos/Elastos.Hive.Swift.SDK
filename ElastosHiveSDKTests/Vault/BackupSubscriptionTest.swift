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

class BackupSubscriptionTest: XCTestCase {
    private var subscription: BackupSubscription?

    override func setUpWithError() throws {
        let testData: TestData = TestData.shared;
        self.subscription = try BackupSubscription(testData.appContext, testData.providerAddress)
    }
    
    func test01Subscribe() throws {
        let lock = XCTestExpectation(description: "wait for subscribe.")
        self.subscription!.subscribe("fake_pricing_plan_name").done({ backupInfo in
            lock.fulfill()
        }).catch({ error in
            XCTFail("\(error)")
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test02Activate() throws {
        let lock = XCTestExpectation(description: "wait for activate.")
        self.subscription!.activate().done ({ _ in
            lock.fulfill()
        }).catch({ error in
            XCTFail("\(error)")
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test03Deactivate() throws {
        let lock = XCTestExpectation(description: "wait for deactivate.")
        self.subscription!.deactivate().done ({ _ in
            lock.fulfill()
        }).catch({ error in
            XCTFail("\(error)")
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testUnsubscribe() throws {
        let lock = XCTestExpectation(description: "wait for unsubscribe.")
        self.subscription!.activate().done ({ _ in
            lock.fulfill()
        }).catch({ error in
            XCTFail("\(error)")
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    

}
