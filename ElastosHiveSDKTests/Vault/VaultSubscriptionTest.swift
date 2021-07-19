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

class VaultSubscriptionTest: XCTestCase {
    private let pricePlanName: String = "Rookie"
    private var _subscription: VaultSubscription?
    private let testData = TestData.shared()
    
    override func setUp() {
        XCTAssertNoThrow(
            _subscription = VaultSubscription(testData.appContext, testData.providerAddress))
    }
    
    public func test01GetPricingPlanList() {
        XCTAssertNoThrow(try { [self] in
            let plans = try await(_subscription!.getPricingPlanList())
            XCTAssertTrue(plans.count > 0)
        }())
    }
    
    public func test02GetPricingPlan() {
        XCTAssertNoThrow(try { [self] in
            let plan = try await(_subscription!.getPricingPlan(pricePlanName))
            XCTAssertTrue(plan.name == pricePlanName)
        }())
    }
    
    // Disable
    public func test03Subscribe() {
        XCTAssertNoThrow(try await(_subscription!.subscribe()))
    }
    
    public func test04CheckSubscription() {
        XCTAssertNoThrow(try { [self] in
            XCTAssertNotNil(try await(_subscription!.checkSubscription()))
        }())
    }
    
    public func test05CheckSubscription() {
        XCTAssertNoThrow({ [self] in
            try await(_subscription!.unsubscribe())
        })
    }
    
    public func test06GetFileHashProcess() {
        XCTAssertNoThrow({ [self] in
            try await(_subscription!.subscribe())
        })
        // TODO
        
    }
}
