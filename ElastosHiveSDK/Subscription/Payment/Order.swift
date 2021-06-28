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
//
//public class Order: Mappable  {
//    
//    private var _orderId: String?
//    private var _did: String?
//    private var _appId: String?
//    private var _pricingInfo: PricingPlan?
//    private var _payTxids: [String]?
//    private var _state: String?
//    private var _type: String?
//    private var _createTime: Double?
//    private var _finishTime: Double?
//    
//    public var orderId: String? {
//        return _orderId
//    }
//    
//    public var did: String? {
//        return _did
//    }
//    
//    public var appId: String? {
//        return _appId
//    }
//    
//    public var pricingInfo: PricingPlan? {
//        return _pricingInfo
//    }
//    
//    public var payTxids: [String]? {
//        return _payTxids
//    }
//    
//    public var state: String? {
//        return _state
//    }
//    
//    public var type: String? {
//        return _type
//    }
//    
//    public var createTime: Double? {
//        return _createTime
//    }
//    
//    public var finishTime: Double? {
//        return _finishTime
//    }
//    
//    required public init?(map: Map) {}
//    
//    public func mapping(map: Map) {
//        _orderId <- map["order_id"]
//        _did <- map["did"]
//        _appId <- map["app_id"]
//        _pricingInfo <- map["pricing_info"]
//        _payTxids <- map["pay_txids"]
//        _state <- map["state"]
//        _type <- map["type"]
//        _createTime <- map["creat_time"]
//        _finishTime <- map["finish_time"]
//    }
//}
