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
    private var _orderId: String?
    private var _subscription: String?
    private var _pricingName: String?
    private var _elaAmount: Double?
    private var _elaAddress: String?
    private var _proof: String?
    private var _createTime: Int64?
    
    public var orderId: String? {
        return _orderId
    }
    
    public var subscription: String? {
        return _subscription
    }
    
    public var pricingName: String? {
        return _pricingName
    }
    
    public var elaAmount: Double? {
        return _elaAmount
    }
  
    public var elaAddress: String? {
        return _elaAddress
    }
    
    public var proof: String? {
        return _proof
    }
    
    public var createTime: Int64? {
        return _createTime
    }
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        _orderId <- map["order_id"]
        _subscription <- map["subscription"]
        _pricingName <- map["pricing_name"]
        _elaAmount <- map["ela_amount"]
        _elaAddress <- map["ela_address"]
        _proof <- map["proof"]
        _createTime <- map["create_time"]
    }
}
