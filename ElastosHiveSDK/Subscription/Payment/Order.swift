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

public class Order: Mappable  {
    private var _orderId: String? // order_id
    private var _subscription: String?
    private var _pricingName: String? // pricing_plan
    private var _payingDid: String? // paying_did
    private var _paymentAmount: Double? // payment_amount
    private var _proof: String?
    private var _createTime: Int64? // create_time
    private var _expirationTime: Int64? // expiration_time
    private var _receivingAddress: String? // receiving_address

    public var orderId: String? {
        return _orderId
    }
    
    public var subscription: String? {
        return _subscription
    }
    
    public var pricingName: String? {
        return _pricingName
    }
    
    public var payingDid: String? {
        return _payingDid
    }
    
    public var paymentAmount: Double? {
        return _paymentAmount
    }

    public var proof: String? {
        return _proof
    }
    
    public var createTime: Int64? {
        return _createTime
    }
    
    public var expirationTime: Int64? {
        return _expirationTime
    }
    
    public var receivingAddress: String? {
        return receivingAddress
    }
      
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        _orderId <- map["order_id"]
        _subscription <- map["subscription"]
        _pricingName <- map["pricing_name"]
        _payingDid <- map["paying_did"]
        _paymentAmount <- map["payment_amount"]
        _proof <- map["proof"]
        _createTime <- map["create_time"]
        _expirationTime <- map["expiration_time"]
        _receivingAddress <- map["receiving_address"]
    }
}
