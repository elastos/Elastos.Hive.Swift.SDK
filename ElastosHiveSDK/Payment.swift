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

public class Payment: PaymentProtocol {
    private var authHelper: VaultAuthHelper
    
    private var vaultUrl: VaultURL
    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
        self.vaultUrl = authHelper.vaultUrl
    }
    
    /// Get vault's payment info
    /// - Returns: Pricing info
    public func getPaymentInfo() -> Promise<PricingInfo> {
        return self.authHelper.checkValid().then { [self] _ -> Promise<PricingInfo> in
            return getAllPricingPlansImp(0)
        }
    }
    
    private func getAllPricingPlansImp(_ tryAgain: Int) -> Promise<PricingInfo> {
        return Promise<PricingInfo> { resolver in
            
            let url = vaultUrl.vaultPackageInfo()
            let response = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
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
    public func getPricingPlan(_ planName: String) -> Promise<PricingPlan> {
        return self.authHelper.checkValid().then { [self] _ -> Promise<PricingPlan> in
            return getPricingPlansImp(planName, 0)
        }
    }
    
    private func getPricingPlansImp(_ planName: String, _ tryAgain: Int) -> Promise<PricingPlan> {
        return Promise<PricingPlan> { resolver in
            let url = vaultUrl.pricingPlan(planName)
            let response = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
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
    public func getPaymentVersion() -> Promise<String> {
        return authHelper.checkValid().then { [self] _ -> Promise<String> in
            return getPaymentVersionImp(0)
        }
    }
    
    private func getPaymentVersionImp(_ tryAgain: Int) -> Promise<String> {
        return Promise<String> { resolver in
            let url = vaultUrl.paymentVersion()
            let response = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
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
    public func placeOrder(_ priceName: String) -> Promise<String> {
        return self.authHelper.checkValid().then { [self] _ -> Promise<String> in
            return placeOrderImp(priceName, 0)
        }
    }
    
    private func placeOrderImp(_ priceName: String, _ tryAgain: Int) -> Promise<String> {
        return Promise<String> { resolver in
            let url = vaultUrl.createOrder()
            let params = ["pricing_name": priceName]
            let response = AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
                placeOrderImp(priceName, 1).done { orderId in
                    resolver.fulfill(orderId)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(json["order_id"].stringValue)
        }
    }
    
    /// Create a order of pricing plan
    /// - Parameter priceName: priceName
    /// - Returns: the order id
    public func payOrder(_ orderId: String, _ txids: Array<String>) -> Promise<Bool> {
        return self.authHelper.checkValid().then { [self] _ -> Promise<Bool> in
            return payOrderImp(orderId, txids, 0)
        }
    }
    
    private func payOrderImp(_ orderId: String, _ txids: Array<String>, _ tryAgain: Int) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let url = vaultUrl.payOrder()
            let params = ["order_id": orderId, "pay_txids": txids] as [String : Any]
            let response = AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
                payOrderImp(orderId, txids, 1).done { success in
                    resolver.fulfill(success)
                }
                .catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }
    
    /// Get order information of vault service purchase
    /// - Parameter orderId: orderId
    /// - Returns: ture, if success
    public func getOrder(_ orderId: String) -> Promise<Order> {
        return self.authHelper.checkValid().then { [self] _ -> Promise<Order> in
            return getOrderImp(orderId, 0)
        }
    }
    
    private func getOrderImp(_ orderId: String, _ tryAgain: Int) -> Promise<Order> {
        return Promise<Order> { resolver in
            let url = vaultUrl.orderInfo(orderId)
            let response = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
                getOrderImp(orderId, 1).done { oreder in
                    resolver.fulfill(oreder)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(Order.deserialize(json["order_info"]))
        }
    }
    
    /// Get user order information list of vault service purchase
    /// - Returns: order list
    public func getAllOrders() -> Promise<Array<Order>> {
        return self.authHelper.checkValid().then { [self] _ -> Promise<Array<Order>> in
            return getAllOrdersImp(0)
        }
    }
    
    private func getAllOrdersImp(_ tryAgain: Int) -> Promise<Array<Order>> {
        return Promise<Array<Order>> { resolver in
            let url = vaultUrl.orderList()
            let response = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
                getAllOrdersImp(1).done { list in
                    resolver.fulfill(list)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            let arrrayJson = json["order_info_list"].arrayValue
            var orderArray: Array<Order> = [ ]
            arrrayJson.forEach { itemJson in
                let order = Order.deserialize(itemJson)
                orderArray.append(order)
            }
            resolver.fulfill(orderArray)
        }
    }

    /// Get using price plan
    /// - Returns: user's using price plan
    public func getUsingPricePlan() -> Promise<UsingPlan> {
        return self.authHelper.checkValid().then { [self] _ -> Promise<UsingPlan> in
            return getUsingPricePlanImp(0)
        }
    }
    
    private func getUsingPricePlanImp(_ tryAgain: Int) -> Promise<UsingPlan> {
        return Promise<UsingPlan> { resolver in
            let url = vaultUrl.serviceInfo()
            let response = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let errorCode = json["_error"]["code"].intValue
            guard errorCode != 404 else {
                throw HiveError.vaultNotFound(des: "vault not found.")
            }
            if json.isEmpty || json["vault_service_info"].isEmpty {
                throw HiveError.vaultNotFound(des: "vault not found.")
            }
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            
            if isRelogin {
                try self.authHelper.signIn()
                getUsingPricePlanImp(1).done { plan in
                    resolver.fulfill(plan)
                }.catch { (error) in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(UsingPlan.deserialize(json["vault_service_info"]))
        }
    }
}
