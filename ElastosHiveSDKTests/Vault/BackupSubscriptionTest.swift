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

class BackupSubscriptionTest: XCTestCase {
    private var _subscription: BackupSubscription?

    override func setUpWithError() throws {
        XCTAssertNoThrow({ [self] in
            let testData = TestData.shared()
            _subscription = BackupSubscription(testData.appContext, testData.providerAddress)
        }())
    }
    
    func test01GetPricingPlanList() {
        XCTAssertNoThrow(try { [self] in
            let plans = try await(_subscription!.getPricingPlanList())
            XCTAssertNotNil(plans)
            XCTAssert(plans.count != 0)
        }())
    }
    
    func test02GetPricingPlan() {
        XCTAssertNoThrow(try { [self] in
            let plan = try await(_subscription!.getPricingPlan("Rookie"))
            XCTAssertNotNil(plan)
            XCTAssert(plan.name == "Rookie")
        }())
    }
    
    func test03Subscribe() {
        XCTAssertNoThrow(try { [self] in
            _ = try await(_subscription!.subscribe())
        }())
    }
    
    func test04CheckSubscription() {
        XCTAssertNoThrow(try { [self] in
            XCTAssertNotNil(try await(_subscription!.checkSubscription()))
        }())
    }
    
    func test06Unsubscribe() {
        XCTAssertNoThrow(try { [self] in
            try await(_subscription!.unsubscribe())
        }())
    }
  
//    func test06GetFileHashProcess() {
//        XCTAssertNoThrow({ [self] in
//            try await(_subscription!.subscribe())
//        })
//        // TODO
//    }
}
