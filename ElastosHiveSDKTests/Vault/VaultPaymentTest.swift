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
    private let PRICING_PLAN_NAME: String = "Rookie"

    private var _paymentService: PaymentService?
    private var _vaultSubscription: VaultSubscription?
    private var _backupSubscription: BackupSubscription?

    override func setUpWithError() throws {
        Log.setLevel(.Debug)
        XCTAssertNoThrow(try { [self] in
            let testData = TestData.shared()
//            _paymentService = try VaultSubscription(testData.appContext, testData.providerAddress)
            _vaultSubscription = try TestData.shared().newVaultSubscription()
            _backupSubscription = try TestData.shared().newBackupSubscription()
            _backupSubscription?.subscribe()
        }())
    }
    
    func test01GetVersion() {
        XCTAssertNoThrow(try { [self] in
            var version = try `await`(_vaultSubscription!.getVersion())
            XCTAssert(version != nil)
            
            version = try `await`(_backupSubscription!.getVersion())
            XCTAssert(version != nil)
        }())
    }
    
    func test02PlaceOrderVault() {
        XCTAssertNoThrow(try { [self] in
            let order = try `await`(_vaultSubscription!.placeOrder(PRICING_PLAN_NAME))
            XCTAssertNotNil(order)
            XCTAssertEqual(order!.subscription, "vault")
            XCTAssertEqual(order!.pricingPlan, PRICING_PLAN_NAME)
            XCTAssertNotNil(order!.payingDid)
            XCTAssertTrue(order!.paymentAmount! > 0)
            XCTAssertTrue(order!.createTime! > 0)
            XCTAssertTrue(order!.expirationTime! > 0)
            XCTAssertNotNil(order!.receivingAddress)
            XCTAssertNotNil(order!.proof)
        }())
    }
    
    // Disabled
    func test030PlaceOrderBackup() {
        XCTAssertNoThrow(try { [self] in
            let order = try `await`(_backupSubscription!.placeOrder(PRICING_PLAN_NAME))
            XCTAssertNotNil(order)
            let subscription = order!.subscription
            XCTAssertTrue((subscription == "vault" || subscription == "backup"))
            XCTAssertEqual(order!.pricingPlan, PRICING_PLAN_NAME)
            XCTAssertNotNil(order!.payingDid)
            XCTAssertTrue(order!.paymentAmount! > 0)
            XCTAssertTrue(order!.createTime! > 0)
            XCTAssertTrue(order!.expirationTime! > 0)
            XCTAssertNotNil(order!.receivingAddress)
            XCTAssertNotNil(order!.proof)

        }())
    }
    
    // Disabled
    func test031SettleOrderVault() {
        XCTAssertNoThrow(try { [self] in
            // TODO: to do pay, please use contract
            let receipt = try `await`(_backupSubscription!.settleOrder(2))
            XCTAssertNotNil(receipt)
            XCTAssertNotNil(receipt!.receiptId)
            XCTAssertNotNil(receipt!.orderId)
            let subscription = receipt!.subscription
            XCTAssertTrue((subscription == "vault"))
            XCTAssertEqual(receipt!.pricingPlan, PRICING_PLAN_NAME)
            XCTAssertTrue(receipt!.paymentAmount! > 0)
            XCTAssertNotNil(receipt!.paidDid)
            XCTAssertTrue(receipt!.createTime! > 0)
            XCTAssertNotNil(receipt!.receivingAddress)
            XCTAssertNotNil(receipt!.receiptProof)
        }())
    }
    
    // Disabled
    func test032SettleOrderBackup() {
        XCTAssertNoThrow(try { [self] in
            // TODO: to do pay, please use contract
            let receipt = try `await`(_backupSubscription!.settleOrder(3))
            XCTAssertNotNil(receipt)
            XCTAssertNotNil(receipt!.receiptId)
            XCTAssertNotNil(receipt!.orderId)
            let subscription = receipt!.subscription
            XCTAssertTrue((subscription == "backup"))
            XCTAssertEqual(receipt!.pricingPlan, PRICING_PLAN_NAME)
            XCTAssertTrue(receipt!.paymentAmount! > 0)
            XCTAssertNotNil(receipt!.paidDid)
            XCTAssertTrue(receipt!.createTime! > 0)
            XCTAssertNotNil(receipt!.receivingAddress)
            XCTAssertNotNil(receipt!.receiptProof)
        }())
    }
    
    // Disabled
    func test040GetOrderVault() {
        XCTAssertNoThrow(try { [self] in
            let order = try `await`(_vaultSubscription!.getOrder(2))
            XCTAssertNotNil(order)
            let subscription = order!.subscription
            XCTAssertTrue((subscription == "vault"))
            XCTAssertEqual(order!.pricingPlan, PRICING_PLAN_NAME)
            XCTAssertTrue(order!.paymentAmount! > 0)
            XCTAssertNotNil(order!.payingDid)
            XCTAssertTrue(order!.createTime! > 0)
            XCTAssertTrue(order!.expirationTime! > 0)
            XCTAssertNotNil(order!.receivingAddress)
            XCTAssertNotNil(order!.proof)
        }())
    }
                         
    // Disabled
   func test041GetOrderBackup() {
        XCTAssertNoThrow(try { [self] in
            let order = try `await`(_backupSubscription!.getOrder(3))
            XCTAssertNotNil(order)
            let subscription = order!.subscription
            XCTAssertTrue((subscription == "backup"))
            XCTAssertEqual(order!.pricingPlan, PRICING_PLAN_NAME)
            XCTAssertTrue(order!.paymentAmount! > 0)
            XCTAssertNotNil(order!.payingDid)
            XCTAssertTrue(order!.createTime! > 0)
            XCTAssertTrue(order!.expirationTime! > 0)
            XCTAssertNotNil(order!.receivingAddress)
            XCTAssertNotNil(order!.proof)
    }())
 }
    // Disabled
    func test05GetOrders() {
        XCTAssertNoThrow(try { [self] in
            let orders = try `await`(_vaultSubscription!.getOrderList())
            XCTAssertNotNil(orders)
            XCTAssertTrue(!orders!.isEmpty)
            let order = orders!.first
            let subscription = order!.subscription
            XCTAssertTrue((subscription == "vault" || subscription == "backup"))
            XCTAssertEqual(order!.pricingPlan, PRICING_PLAN_NAME)
            XCTAssertNotNil(order!.payingDid)
            XCTAssertTrue(order!.paymentAmount! > 0)
            XCTAssertTrue(order!.createTime! > 0)
            XCTAssertTrue(order!.expirationTime! > 0)
            XCTAssertNotNil(order!.receivingAddress)
            XCTAssertNotNil(order!.proof)
        }())
    }

    // Disabled
    func test06GetReceipt() {
        XCTAssertNoThrow(try { [self] in
            let receipt = try `await`(_vaultSubscription!.getReceipt(2))
            XCTAssertNotNil(receipt)
            XCTAssertNotNil(receipt!.receiptId)
            XCTAssertNotNil(receipt!.orderId)
            let subscription = receipt!.subscription
            XCTAssertTrue((subscription == "vault" || subscription == "backup"))
            XCTAssertEqual(receipt!.pricingPlan, PRICING_PLAN_NAME)
            XCTAssertNotNil(receipt!.paidDid)
            XCTAssertTrue(receipt!.paymentAmount! > 0)
            XCTAssertTrue(receipt!.createTime! > 0)
            XCTAssertNotNil(receipt!.receivingAddress)
            XCTAssertNotNil(receipt!.receiptProof)
        }())
    }

    //Disabled
    func test07GetReceipts() {
        XCTAssertNoThrow(try { [self] in
            let receipts = try `await`(_vaultSubscription!.getReceipts())
            XCTAssertNotNil(receipts)
            XCTAssertTrue(receipts!.count > 0)
            let receipt = receipts!.first
            XCTAssertNotNil(receipt!.receiptId)
            XCTAssertNotNil(receipt!.orderId)
            let subscription = receipt!.subscription
            XCTAssertTrue((subscription == "vault" || subscription == "backup"))
            XCTAssertEqual(receipt!.pricingPlan, PRICING_PLAN_NAME)
            XCTAssertNotNil(receipt!.paidDid)
            XCTAssertTrue(receipt!.paymentAmount! > 0)
            XCTAssertTrue(receipt!.createTime! > 0)
            XCTAssertNotNil(receipt!.receivingAddress)
            XCTAssertNotNil(receipt!.receiptProof)
        }())
    }
}

