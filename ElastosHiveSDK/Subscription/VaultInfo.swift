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

/// This contains the details of the vault service.
public class VaultInfo: Mappable {
    public var _serviceDid: String?
    public var _storageQuota: Int?
    public var _storageUsed: Int?
    public var _created: Int64?
    public var _updated: Int64?
    public var _pricingPlan: Int64?
    public var _appCount: Int? // app_count
    public var _accessCount: Int? // access_count
    public var _accessAmount: Int? // access_amount
    public var _accessLastTime: Int? // access_last_time
    
    public var serviceDid: String? {
        return _serviceDid
    }
    
    public var storageQuota: Int? {
        return _storageQuota
    }

    public var storageUsed: Int? {
        return _storageUsed
    }

    public var created: Int64? {
        return _created
    }
    
    public var updated: Int64? {
        return _updated
    }

    public var pricingPlan: Int64? {
        return _pricingPlan
    }
    
    public var appCount: Int? {
        return _appCount
    }
    public var accessCount: Int? {
        return _accessCount
    }
    public var accessAmount: Int? {
        return _accessAmount
    }
    public var accessLastTime: Int? {
        return _accessLastTime
    }

    public required init?(map: Map) {}

    public func mapping(map: Map) {
        _serviceDid <- map["service_did"]
        _storageQuota <- map["storage_quota"]
        _storageUsed <- map["storage_used"]
        _created <- map["created"]
        _updated <- map["updated"]
        _pricingPlan <- map["pricing_plan"]
        _appCount <- map["app_count"]
        _accessCount <- map["access_count"]
        _accessAmount <- map["access_amount"]
        _accessLastTime <- map["access_last_time"]
    }
}
