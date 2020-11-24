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

public class Payment: NSObject {
    private var authHelper: VaultAuthHelper
    
    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }
    
    /// Get vault's payment info
    /// - Returns: Pricing info
    public func getPaymentInfo() -> HivePromise<PricingInfo> {
        return HivePromise<PricingInfo> { resover in
            _ = self.authHelper.checkValid().done { [self] _ in
                do {
                    resover.fulfill(try getAllPricingPlansImp(0))
                }
                catch {
                    resover.reject(error)
                }
            }
        }
    }

    private func getAllPricingPlansImp(_ tryAgain: Int) throws -> PricingInfo {
        let url = VaultURL.sharedInstance.vaultPackageInfo()
        let response = Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Header(authHelper).headers()).responseJSON()
        let json = try VaultApi.handlerJsonResponse(response)
        let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
        
        if tryLogin {
            return try getAllPricingPlansImp(1)
        }
        let info = PricingInfo.deserialize(json)
        return info
    }

    /// Get vault pricing plan information by plan name
    /// - Returns: the instance of PricingPlan
    public func getPricingPlan(_ planName: String) -> HivePromise<PricingPlan> {
        return HivePromise<PricingPlan> { resover in
            _ = self.authHelper.checkValid().done { [self] _ in
                do {
                    resover.fulfill(try getPricingPlansImp(planName, 0))
                }
                catch {
                    resover.reject(error)
                }
            }
        }
    }
    
    private func getPricingPlansImp(_ planName: String, _ tryAgain: Int) throws -> PricingPlan {
        let url = VaultURL.sharedInstance.pricingPlan(planName)
        let response = Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Header(authHelper).headers()).responseJSON()
        let json = try VaultApi.handlerJsonResponse(response)
        let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
        
        if tryLogin {
            return try getPricingPlansImp(planName, 1)
        }
        let plan = PricingPlan.deserialize(json)
        return plan
    }
}
