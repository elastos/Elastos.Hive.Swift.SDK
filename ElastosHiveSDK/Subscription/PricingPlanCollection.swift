/*
 * Copyright (c) 2019 Elastos Foundation
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

public class PricingPlanCollection: Mappable {
    private var _backupPlans: Array<PricingPlan>?
    private var _pricingPlans: Array<PricingPlan>?
    private var _version: String?
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        _backupPlans <- map["backupPlans"]
        _pricingPlans <- map["pricingPlans"]
        _version <- map["version"]
    }
    
    public var backupPlans: Array<PricingPlan>? {
        return _backupPlans
    }
    
    public var pricingPlans: Array<PricingPlan>? {
        return _pricingPlans
    }
    
    public var version: String? {
        return _version
    }
}
