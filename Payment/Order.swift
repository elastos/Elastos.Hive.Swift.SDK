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

public class Order: Result {
    private let ORDER_ID = "order_id"
    private let DID = "did"
    private let APP_ID = "app_id"
    private static let PRICING_INFO = "pricing_info"
    private let PAY_TXIDS = "pay_txids"
    private let STATE = "state"
    private let CREAT_TIME = "creat_time"
    private let FINISH_TIME = "finish_time"
    private var _packageInfo: PricingPlan?

    public var finish_time: Int {
        return paramars[FINISH_TIME].intValue
    }
    
    public var orderId: String {
        return paramars[ORDER_ID].stringValue
    }
    
    public var did: String {
        return paramars[DID].stringValue
    }
    
    public var appId: String {
        return paramars[APP_ID].stringValue
    }
    
    public var packageInfo: PricingPlan? {
        return _packageInfo
    }
    
    public var payTxids: Array<String> {
        var list: Array<String> = []
        paramars[PAY_TXIDS].arrayValue.forEach { vaule in
            list.append(vaule.stringValue)
        }
        return list
    }
    
    public var state: String {
        return paramars[STATE].stringValue
    }
    
    public var creatTime: Int {
        return paramars[CREAT_TIME].intValue
    }
    
    public var finishTime: Int {
        return paramars[FINISH_TIME].intValue
    }
    
    public class func deserialize(_ content: String) throws -> Order {
        let data = content.data(using: String.Encoding.utf8)
        let paramars = try JSONSerialization
            .jsonObject(with: data!,
                        options: .mutableContainers) as? [String : Any] ?? [: ]
        let json = JSON(paramars)
        let order = Order(json)
        order._packageInfo = PricingPlan(json[PRICING_INFO])
        
        return order
    }
    
    class func deserialize(_ content: JSON) -> Order {
        let order = Order(content)
        order._packageInfo = PricingPlan.deserialize(content[PRICING_INFO])
        
        return order
    }
}

