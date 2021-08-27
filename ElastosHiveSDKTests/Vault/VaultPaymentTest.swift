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

class VaultPaymentTest: XCTestCase {
    private let _orderId: String = "6127343bbfc927fef353e6a7"
    private let _transId: String = "a7e5cd568e15523e656330c892045b2fd1640bbe62ee28531e23908d1c2862ec"
    private let _pricingPlanName: String = "Rookie"

    private var _paymentService: PaymentService?

    override func setUpWithError() throws {
        Log.setLevel(.Debug)
        XCTAssertNoThrow(try { [self] in
            let testData = TestData.shared()
            _paymentService = try VaultSubscription(testData.appContext, testData.providerAddress)
        }())
    }
    
    func test01GetVersion() {
        XCTAssertNoThrow(try { [self] in
            let version = try await(_paymentService!.getVersion())
            XCTAssert(version != nil)
        }())
    }
    
    func test02PlaceOrder() {
        XCTAssertNoThrow(try { [self] in
            let order = try await(_paymentService!.placeOrder(_pricingPlanName))
            XCTAssertNotNil(order)
        }())
    }
    
    // Disabled
    func test03PayOrder() {
        XCTAssertNoThrow(try { [self] in
            let receipt = try await(_paymentService!.payOrder(_orderId, _transId))
            XCTAssertNotNil(receipt.receiptId)
            XCTAssertNotNil(receipt.orderId)
        }())
    }
    
    // Disabled
    func test04GetOrder() {
        XCTAssertNoThrow(try { [self] in
            let order = try await(_paymentService!.getOrder(_orderId))
            XCTAssertNotNil(order)
            XCTAssertNotNil(order.orderId)
        }())
    }
    
    // Disabled
    func test05GetOrders() {
        XCTAssertNoThrow(try { [self] in
            let orders = try await(_paymentService!.getOrderList())
            XCTAssertNotNil(orders)
            XCTAssert(orders.count != 0)
        }())
    }
    
    // Disabled
    func test06GetReceipt() {
        XCTAssertNoThrow(try { [self] in
            let receipt = try await(_paymentService!.getReceipt(_orderId))
            XCTAssertNotNil(receipt)
            XCTAssertNotNil(receipt.receiptId)
            XCTAssertNotNil(receipt.orderId)
        }())
    }

    //Disabled
    func test07MakeOrderProcess() {
        XCTAssertNoThrow(try { [self] in
            var order = try await(_paymentService!.placeOrder(_pricingPlanName))
            XCTAssertNotNil(order)
            XCTAssertNotNil(order.orderId)
            order = try await(_paymentService!.getOrder(order.orderId!))
            XCTAssertNotNil(order)
            XCTAssertNotNil(order.orderId)
            let receipt = try await(_paymentService!.payOrder(order.orderId!, _transId))
            XCTAssertNotNil(receipt)
            XCTAssertNotNil(receipt.receiptId)
            XCTAssertNotNil(receipt.orderId)
        }())
    }
}

