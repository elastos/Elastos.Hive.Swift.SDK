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

public class PricingPlan: Result {
    private let NAME = "name"
    private let MAXSTORAGE = "maxStorage"
    private let SERVICE_DAYS = "serviceDays"
    private let AMOUNT = "amount"
    private let CURENCY = "currency"
    
    public var name: String {
        return paramars[NAME].stringValue
    }
    
    public var maxStorage: Int {
        return paramars[MAXSTORAGE].intValue
    }
    
    public var serviceDays: Int {
        return paramars[SERVICE_DAYS].intValue
    }
    
    public var amount: Float {
        return paramars[AMOUNT].floatValue
    }
    
    public var currency: String {
        return paramars[CURENCY].stringValue
    }
    
    public class func deserialize(_ content: String) throws -> PricingPlan {
        let data = content.data(using: String.Encoding.utf8)
        let paramars = try JSONSerialization
            .jsonObject(with: data!,
                        options: .mutableContainers) as? [String : Any] ?? [: ]
        return PricingPlan(JSON(paramars))
    }
    
    class func deserialize(_ content: JSON) -> PricingPlan {
        return PricingPlan(content)
    }
}
