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

class VaultPaymentTest: XCTestCase {
    let planName: String = "Rookie"
    private var paymentService: VaultSubscription?

    override func setUpWithError() throws {
        Log.setLevel(.Debug)
        let testData = TestData.shared
        self.paymentService = try VaultSubscription(testData.appContext, testData.providerAddress)
    }
    
    func testGetPricingPlanList() {
        let lock = XCTestExpectation(description: "wait for get pricing plan list.")
        self.paymentService!.getPricingPlanList().done({ pricingPlan in
            XCTAssert(pricingPlan!.count > 0)
            lock.fulfill()
        }).catch { error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
//    func testGetPricingPlan() {
//        let lock = XCTestExpectation(description: "wait for get pricing plan.")
//        self.paymentService!.getPricingPlan(self.planName).done({ pricingPlan in
//            XCTAssert(pricingPlan != nil)
//            lock.fulfill()
//        }).catch { error in
//            XCTFail()
//            lock.fulfill()
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }

    // TODO
//    func testOrderProcess() {
//        let lock = XCTestExpectation(description: "wait for get pricing plan.")
//        try! self.paymentService!.placeOrder(self.planName).then({ order -> Promise<Receipt> in
//            
//            return self.paymentService!.payOrder(order!.orderId!, [])
//        }).done({ receipt in
//            print(receipt)
//        }).catch { error in
//            XCTFail()
//            lock.fulfill()
//        }
//        
//        self.wait(for: [lock], timeout: 1000.0)
//    }
    
}
