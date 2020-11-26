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
        return self.authHelper.checkValid().then { [self] _ -> HivePromise<PricingInfo> in
            return getAllPricingPlansImp(0)
        }
    }
    
    private func getAllPricingPlansImp(_ tryAgain: Int) -> HivePromise<PricingInfo> {
        return HivePromise<PricingInfo> { resolver in
            
            let url = VaultURL.sharedInstance.vaultPackageInfo()
            let response = Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if tryLogin {
                try self.authHelper.signIn()
                getAllPricingPlansImp(1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            let info = PricingInfo.deserialize(json)
            resolver.fulfill(info)
        }
    }

    /// Get vault pricing plan information by plan name
    /// - Returns: the instance of PricingPlan
    public func getPricingPlan(_ planName: String) -> HivePromise<PricingPlan> {
        return self.authHelper.checkValid().then { [self] _ -> HivePromise<PricingPlan> in
            return getPricingPlansImp(planName, 0)
        }
    }
    
    private func getPricingPlansImp(_ planName: String, _ tryAgain: Int) -> HivePromise<PricingPlan> {
        return HivePromise<PricingPlan> { resolver in
            let url = VaultURL.sharedInstance.pricingPlan(planName)
            let response = Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if tryLogin {
                try self.authHelper.signIn()
                getPricingPlansImp(planName, 1).done { result in
                    resolver.fulfill(result)
                }
                .catch { error in
                    resolver.reject(error)
                }
            }
            let plan = PricingPlan.deserialize(json)
            resolver.fulfill(plan)
        }
    }
    
    /// Get payment version
    /// - Returns: payment vresion
    public func getPaymentVersion() -> HivePromise<String> {
        return authHelper.checkValid().then { [self] _ -> HivePromise<String> in
            return getPaymentVersionImp(0)
        }
    }
    
    private func getPaymentVersionImp(_ tryAgain: Int) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            let url = VaultURL.sharedInstance.paymentVersion()
            let response = Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if tryLogin {
                try self.authHelper.signIn()
                getPaymentVersionImp(1).done { result in
                    resolver.fulfill(result)
                }
                .catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(json["version"].stringValue)
        }
    }

    /// Create a order of pricing plan
    /// - Parameter priceName: priceName
    /// - Returns: the order id
    public func placeOrder(_ priceName: String) -> HivePromise<String> {
        HivePromise<String> { resolver in
           _ = authHelper.checkValid().done { [self] _ in
                do {
                    try resolver.fulfill(placeOrderImp(priceName, 0))
                }
                catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    private func placeOrderImp(_ priceName: String, _ tryAgain: Int) throws -> String {
        let url = VaultURL.sharedInstance.createOrder()
        let params = ["pricing_name": priceName]
        let response = Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: Header(authHelper).headers()).responseJSON()
        let json = try VaultApi.handlerJsonResponse(response)
        let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
        
        if tryLogin {
            try self.authHelper.signIn()
            return try placeOrderImp(priceName, 1)
        }
        return json["order_id"].stringValue
    }
    
    /// Create a order of pricing plan
    /// - Parameter priceName: priceName
    /// - Returns: the order id
    public func payOrder(_ orderId: String, _ txids: Array<String>) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            _ = authHelper.checkValid().done { [self] _ in
                do {
                    try resolver.fulfill(payOrderImp(orderId, txids, 0))
                }
                catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    private func payOrderImp(_ orderId: String, _ txids: Array<String>, _ tryAgain: Int) throws -> Bool {
        let url = VaultURL.sharedInstance.payOrder()
        let params = ["order_id": orderId, "pay_txids": txids] as [String : Any]
        let response = Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: Header(authHelper).headers()).responseJSON()
        let json = try VaultApi.handlerJsonResponse(response)
        let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
        
        if tryLogin {
            try self.authHelper.signIn()
            return try payOrderImp(orderId, txids, 1)
        }
        return true
    }
    
    /// Get order information of vault service purchase
    /// - Parameter orderId: orderId
    /// - Returns: ture, if success
    public func getOrder(_ orderId: String) -> HivePromise<Order> {
        HivePromise<Order> { resolver in
            _ = authHelper.checkValid().done { [self] _ in
                do {
                    try resolver.fulfill(getOrderImp(orderId, 0))
                }
                catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    private func getOrderImp(_ orderId: String, _ tryAgain: Int) throws -> Order {
        let url = VaultURL.sharedInstance.orderInfo(orderId)
        let response = Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Header(authHelper).headers()).responseJSON()
        let json = try VaultApi.handlerJsonResponse(response)
        let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
        
        if tryLogin {
            try self.authHelper.signIn()
            return try getOrderImp(orderId, 1)
        }
        
        return Order.deserialize(json["order_info"])
    }
    
    /// Get user order information list of vault service purchase
    /// - Returns: order list
    public func getAllOrders() -> HivePromise<Array<Order>> {
        HivePromise<Array<Order>> { resolver in
            _ = authHelper.checkValid().done { [self] _ in
                do {
                    try resolver.fulfill(getAllOrdersImp(0))
                }
                catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    private func getAllOrdersImp(_ tryAgain: Int) throws -> Array<Order> {
        let url = VaultURL.sharedInstance.orderList()
        let response = Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Header(authHelper).headers()).responseJSON()
        let json = try VaultApi.handlerJsonResponse(response)
        let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
        
        if tryLogin {
            try self.authHelper.signIn()
            return try getAllOrdersImp(1)
        }
        let arrrayJson = json["order_info_list"].arrayValue
        var orderArray: Array<Order> = [ ]
        arrrayJson.forEach { itemJson in
            let order = Order.deserialize(itemJson)
            orderArray.append(order)
        }
        return orderArray
    }

    /// Get using price plan
    /// - Returns: user's using price plan
    public func getUsingPricePlan() -> HivePromise<UsingPlan> {
        HivePromise<UsingPlan> { resolver in
            _ = authHelper.checkValid().done { [self] _ in
                do {
                    try resolver.fulfill(getUsingPricePlanImp(0))
                }
                catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    private func getUsingPricePlanImp(_ tryAgain: Int) throws -> UsingPlan {
        let url = VaultURL.sharedInstance.serviceInfo()
        let response = Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Header(authHelper).headers()).responseJSON()
        let json = try VaultApi.handlerJsonResponse(response)
        let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
        
        if tryLogin {
            try self.authHelper.signIn()
            return try getUsingPricePlanImp(1)
        }
        return UsingPlan.deserialize(json["vault_service_info"])
    }
}
