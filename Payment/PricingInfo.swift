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

public class PricingInfo: Result {
    private let PRICINGPLANS = "pricingPlans"
    private let PAYMENTSETTINGS = "paymentSettings"
    private var _pricingPlans: Array<PricingPlan> = [ ]
    
    public var pricingPlans: Array<PricingPlan> {
      return _pricingPlans
    }
    
    public var paymentSettings: String {
        return paramars[PAYMENTSETTINGS].stringValue
    }
    
    public class func deserialize(_ content: String) throws -> PricingInfo {
        let data = content.data(using: String.Encoding.utf8)
        let paramars = try JSONSerialization
            .jsonObject(with: data!,
                        options: .mutableContainers) as? [String : Any] ?? [: ]
        let json = JSON(paramars)
        let info = PricingInfo(json)
        for item in json["pricingPlans"].arrayValue {
            let plan = PricingPlan(item)
            info._pricingPlans.append(plan)
        }
        return info
    }
}

