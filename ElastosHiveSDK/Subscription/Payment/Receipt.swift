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
    private var _receiptId: String?
    private var _orderId: String?
    private var _transactionId: String?
    private var _pricingName: String?
    private var _paidDid: String?
    private var _elaAmount: Double?
    private var _proof: String?

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
    
    public var transactionId: String? {
        get {
            return _transactionId
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
    
    public var elaAmount: Double? {
        get {
            return _elaAmount
        }
    }
    
    public var proof: String? {
        get {
            return _proof
        }
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        _receiptId <- map["receipt_id"]
        _orderId <- map["order_id"]
        _transactionId <- map["transaction_id"]
        _pricingName <- map["pricing_name"]
        _paidDid <- map["paid_did"]
        _elaAmount <- map["ela_amount"]
        _proof <- map["proof"]
    }
}

