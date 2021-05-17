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

/**
 * Helper class for vault/backup subscription.
 */
public class PaymentServiceRender {
    
    private var _serviceEndpoint: ServiceEndpoint
    public init(_ serviceEndpoint: ServiceEndpoint) {
        self._serviceEndpoint = serviceEndpoint
    }
    
    public func getPricingPlanList() -> Promise<Array<PricingPlan>?> {
        return Promise<Void>.async().then { [self] _ -> Promise<Array<PricingPlan>?> in
            return Promise<Array<PricingPlan>?> { resolver in
                do {
                    let response = try HiveAPi.request(url: self._serviceEndpoint.connectionManager.hiveApi.getPackageInfo(),
                                                       method: .get,
                                                       headers: self._serviceEndpoint.connectionManager.headers()).get(PaymentPackageResponse.self)
                    resolver.fulfill(response.pricingPlans)
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func getBackupPlanList() -> Promise<Array<PricingPlan>?> {
        return Promise<Void>.async().then { [self] _ -> Promise<Array<PricingPlan>?> in
            return Promise<Array<PricingPlan>?> { resolver in
                do {
                    let response = try HiveAPi.request(url: self._serviceEndpoint.connectionManager.hiveApi.getPackageInfo(),
                                                       method: .get,
                                                       headers: self._serviceEndpoint.connectionManager.headers()).get(PaymentPackageResponse.self)
                    resolver.fulfill(response.backupPlans)
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }

    public func getPricingPlan(_ planName: String) -> Promise<PricingPlan?> {
        return Promise<Void>.async().then { [self] _ -> Promise<PricingPlan?> in
            return Promise<PricingPlan?> { resolver in
                let response = try HiveAPi.request(url: self._serviceEndpoint.connectionManager.hiveApi.getPricingPlan(planName),
                                                   method: .get,
                                                   headers: self._serviceEndpoint.connectionManager.headers()).get(PaymentPlanResponse.self)
                let pricingPlan: PricingPlan  = PricingPlan()
                pricingPlan.amount = response.amount
                pricingPlan.currency = response.currency
                pricingPlan.maxStorage = response.maxStorage
                pricingPlan.name = response.name
                pricingPlan.serviceDays = response.serviceDays
                
                resolver.fulfill(pricingPlan)
            }
        }
    }
    
    public func getBackupPlan(_ backplanName: String) -> Promise<PricingPlan?> {
        return Promise<Void>.async().then { [self] _ -> Promise<PricingPlan?> in
            return Promise<PricingPlan?> { resolver in
                let response = try HiveAPi.request(url: self._serviceEndpoint.connectionManager.hiveApi.getBackupPlan(backplanName),
                                                   method: .get,
                                                   headers: self._serviceEndpoint.connectionManager.headers()).get(PaymentPlanResponse.self)
                let pricingPlan: PricingPlan  = PricingPlan()
                pricingPlan.amount = response.amount
                pricingPlan.currency = response.currency
                pricingPlan.maxStorage = response.maxStorage
                pricingPlan.name = response.name
                pricingPlan.serviceDays = response.serviceDays
                
                resolver.fulfill(pricingPlan)
            }
        }
    }
    
    public func createPricingOrder(_ planName: String) -> Promise<String?> {
        return createOrder(planName, nil)
    }
    
    public func createBackupOrder(_ backupPlanName: String) -> Promise<String?> {
        return createOrder(nil, backupPlanName)
    }
    
    public func createOrder(_ planName: String?, _ backupPlanName: String?) -> Promise<String?> {
        return Promise<Void>.async().then { [self] _ -> Promise<String?> in
            return Promise<String?> { resolver in
                do {
                    let params = ["pricing_name": planName, "backing_name": ""]
                    let response: HiveResponse = try HiveAPi.request(url: self._serviceEndpoint.connectionManager.hiveApi.createOrder(),
                                                                     method: .post,
                                                                     parameters: params as Parameters,
                                                                     headers: try self._serviceEndpoint.connectionManager.headers()).get(HiveResponse.self)
                    resolver.fulfill((response.json["order_id"] as! String))
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func payOrder(_ orderId: String, _ transIds: [String]) -> Promise<Receipt?> {
        return Promise<Void>.async().then { [self] _ -> Promise<Receipt?> in
            return Promise<Receipt?> { resolver in
                let params = ["order_id": orderId, "pay_txids": transIds] as [String : Any]
                _ = try HiveAPi.request(url: self._serviceEndpoint.connectionManager.hiveApi.payOrder,
                method: .post,
                parameters: params,
                headers: try self._serviceEndpoint.connectionManager.headers()).get(HiveResponse.self)
                resolver.fulfill(Receipt())
            }
        }
    }
    
    public func getOrderInfo(_ orderId: String) -> Promise<Order?> {
        return Promise<Void>.async().then { _ -> Promise<Order?> in
            return Promise<Order?> { resolver in
                do {
                    let orderInfoResponse = try HiveAPi.request(url: self._serviceEndpoint.connectionManager.hiveApi.orderInfo(orderId),
                                                                method: .get,
                                                                headers: try self._serviceEndpoint.connectionManager.headers()).get(OrderInfoResponse.self)
                    resolver.fulfill(orderInfoResponse.orderInfo)
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
}
