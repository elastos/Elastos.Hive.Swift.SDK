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

class VaultSubscriptionTest: XCTestCase {
//    private var subscription: VaultSubscription?
//    private var hiveAPI: HiveAPi?
//    private var orderId = "5fbdf4ee46c829dc73a9a3d2"
//
//    override func setUpWithError() throws {
//        let testData = TestData.shared;
//        self.subscription = try VaultSubscription(testData.appContext, testData.providerAddress);
//    }
//    
//    func test01Subscribe() throws {
//        let lock = XCTestExpectation(description: "wait for test subscribe.")
//        self.subscription!.subscribe("free").done({ (vaultInfo) in
//            
//        }).catch({ error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        })
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//    
//    func test02Activate() throws {
//        let lock = XCTestExpectation(description: "wait for test activate.")
//        self.subscription!.activate().done({ _ in
//            XCTAssertTrue(true)
//            lock.fulfill()
//        }).catch({ error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        })
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//    
//    
//    func test03CheckSubscription() throws {
//        let lock = XCTestExpectation(description: "wait for test check subscription.")
//        self.subscription!.checkSubscription().done ({ vaultInfo in
//            XCTAssertTrue(true)
//            lock.fulfill()
//        }).catch({ error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        })
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//
//    func test04Deactivate() throws {
//        let lock = XCTestExpectation(description: "wait for test deactivate.")
//        self.subscription!.deactivate().done({ _ in
//            XCTAssertTrue(true)
//            lock.fulfill()
//        }).catch({ error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        })
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//    
//    
//    
//    func test05Unsubscribe() throws {
//        let lock = XCTestExpectation(description: "wait for test unsubscribe.")
//        self.subscription!.unsubscribe().done({ _ in
//            XCTAssertTrue(true)
//            lock.fulfill()
//        }).catch({ error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        })
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//
//    
//    func test06GetFileHashProcess() throws {
//        let lock = XCTestExpectation(description: "wait for test deactivate.")
//        self.subscription!.subscribe("free").then({ vaultInfo -> Promise<Void> in
//            return self.subscription!.activate()
//        }).then { _ -> Promise<Void> in
//            return Promise<Void> { resolver in
//                FilesServiceTest().test05Hash()
//                resolver.fulfill(Void())
//            }
//        }.then { _ -> Promise<Void> in
//            return self.subscription!.deactivate()
//        }.then { _ -> Promise<Void> in
//            return self.subscription!.unsubscribe()
//        }.done { _ in
//            XCTAssert(true)
//            lock.fulfill()
//        }.catch { error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }

}
