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

import Foundation
import ObjectMapper

public class Receipt: Mappable  {
    private var _receiptId: String? // receipt_id
    private var _orderId: String? // order_id
    private var _subscription: String? // subscription
    private var _pricingPlan: String? // pricing_plan
    private var _paymentAmount: Double? // payment_amount
    private var _paidDid: String? // paid_did
    private var _createTime: Int? // create_time
    private var _receivingAddress: String? // receiving_address
    private var _receiptProof: String? // receipt_proof

    public init() {
        
    }
    
    public var receiptId: String? {
        get {
            return _receiptId
        }
    }
    
    public var orderId: String? {
        get {
            return _orderId
        }
    }
    
    public var subscription: String? {
        get {
            return _subscription
        }
    }
    
    public var pricingPlan: String? {
        get {
            return _pricingPlan
        }
    }
    
    public var paymentAmount: Double? {
        get {
            return _paymentAmount
        }
    }
    
    public var paidDid: String? {
        get {
            return _paidDid
        }
    }
    
    public var createTime: Int? {
        get {
            return _createTime
        }
    }

    public var pricingName: String? {
        get {
            return _pricingName
        }
    }
    
    public var paidDid: String? {
        get {
            return _paidDid
        }
    }
    
    public var receivingAddress: String? {
        get {
            return _receivingAddress
        }
    }
    
    public var receiptProof: String? {
        get {
            return _receiptProof
        }
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        _receiptId <- map["receipt_id"]
        _orderId <- map["order_id"]
        _subscription <- map["subscription"]
        _pricingPlan <- map["pricing_plan"]
        _paymentAmount <- map["payment_amount"]
        _paidDid <- map["paid_did"]
        _createTime <- map["create_time"]
        _receivingAddress <- map["receiving_address"]
        _receiptProof <- map["receipt_proof"]
    }
}
