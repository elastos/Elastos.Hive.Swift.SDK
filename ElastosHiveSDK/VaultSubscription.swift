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

public class VaultInfo: Mappable {
    var appInstanceDid: String?
    var userDid: String?
    var serviceDid: String?
    
    public required init?(map: Map) {}

    public func mapping(map: Map) {
        appInstanceDid <- map["appInstanceDid"]
        userDid <- map["userDid"]
        serviceDid <- map["serviceDid"]
    }
}

public class SubscriptionRender: ServiceEndpoint, SubscriptionService, PaymentService {
    
    public func subscribe<T>(_ pricingPlan: String, type: T.Type) -> Promise<T> {
        // TODO
        return Promise<T> { resolver in
            resolver.fulfill(true as! T)
        }
    }
    
    public func checkSubscription() -> Promise<Void> {
        // TODO
        return Promise<Void> { resolver in
            resolver.fulfill(Void())
        }
    }
    
    public func getReceipt(_ receiptId: String) -> Promise<Receipt> {
        // TODO
        return Promise<Receipt> { resolver in
            resolver.fulfill(true as! Receipt)
        }
    }
        
    public func subscribe<T: Mappable>(_ pricingPlan: String?,_ type: T.Type) throws -> Promise<T> {
        return Promise<T> { resolver in
            let response = AF.request(self.connectionManager.hiveApi.createVault(), method: .post, encoding: JSONEncoding.default, headers: HiveHeader(nil).headers()).responseJSON()
            
            switch response.result {
            case .success(let json):
                resolver.fulfill(T(JSON: json as! [String : Any])!)
            case .failure(let error):
                resolver.reject(error)
            }
        }
    }
    
    public func unsubscribe() throws -> Promise<Void> {
        return Promise<Void> { resolver in
            let response = AF.request(self.connectionManager.hiveApi.removeVault(), method: .post, encoding: JSONEncoding.default, headers: HiveHeader(nil).headers()).responseJSON()
            
            switch response.result {
            case .success(let json):
                resolver.fulfill(Void())
            case .failure(let error):
                resolver.reject(error)
            }
        }
    }
    
    public func activate() throws -> Promise<Void> {
        return Promise<Void> { resolver in
            let response = AF.request(self.connectionManager.hiveApi.unfreeze(), method: .post, encoding: JSONEncoding.default, headers: HiveHeader(nil).headers()).responseJSON()
            
            switch response.result {
            case .success(let json):
                resolver.fulfill(Void())
            case .failure(let error):
                resolver.reject(error)
            }
        }
    }
    
    public func deactivate() throws -> Promise<Void> {
        return Promise<Void> { resolver in
            let response = AF.request(self.connectionManager.hiveApi.freeze(), method: .post, encoding: JSONEncoding.default, headers: HiveHeader(nil).headers()).responseJSON()
            
            switch response.result {
            case .success(let json):
                resolver.fulfill(Void())
            case .failure(let error):
                resolver.reject(error)
            }
        }
    }
    
    public func checkSubscription() throws -> Promise<VaultInfo> {
        return Promise<VaultInfo> { resolver in
            resolver.fulfill(true as! VaultInfo)
        }
    }
    
    
    public func getPricingPlanList() -> Promise<Array<PricingPlan>> {
        return Promise<Void>.async().then { [self] _ -> Promise<Array<PricingPlan>> in
            // TODO
            return Promise<Array<PricingPlan>> { resolver in
                do {
                    let url = self.connectionManager.hiveApi.getPackageInfo()
                    let response = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: self.connectionManager.hiveHeader.headers()).responseJSON()
                    let json = try VaultApi.handlerJsonResponse(response)
                    let plan = PricingPlan.deserialize(json)
                    resolver.fulfill([plan])
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }

    public func getPricingPlan(_ planName: String) -> Promise<PricingPlan> {
        return Promise<Void>.async().then { [self] _ -> Promise<PricingPlan> in
            return Promise<PricingPlan> { resolver in
                do {
                    let url = self.connectionManager.hiveApi.getPricingPlan(planName)
                    let response = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: self.connectionManager.hiveHeader.headers()).responseJSON()
                    let json = try VaultApi.handlerJsonResponse(response)
                    let plan = PricingPlan.deserialize(json)
                    resolver.fulfill(plan)
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func placeOrder(_ planName: String) -> Promise<Order> {
        return Promise<Void>.async().then { [self] _ -> Promise<Order> in
            return Promise<Order> { resolver in
                do {
                    let url = self.connectionManager.hiveApi.createOrder()
                    let params = ["pricing_name": planName]
                    let response = AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.connectionManager.hiveHeader.headers()).responseJSON()
                    let json = try VaultApi.handlerJsonResponse(response)
                    resolver.fulfill(Order.deserialize(json["order_info"]))
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }

    public func getOrder(_ orderId: String) -> Promise<Order> {
        return Promise<Void>.async().then { [self] _ -> Promise<Order> in
            return Promise<Order> { resolver in
                do {
                    let url = self.connectionManager.hiveApi.orderInfo(orderId)
                    let response = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: self.connectionManager.hiveHeader.headers()).responseJSON()
                    let json = try VaultApi.handlerJsonResponse(response)
                    resolver.fulfill(Order.deserialize(json["order_info"]))
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func payOrder(_ orderId: String, _ transId: String) -> Promise<Receipt> {
        return Promise<Void>.async().then { [self] _ -> Promise<Receipt> in
            return Promise<Receipt> { resolver in
                do {
                    let url = self.connectionManager.hiveApi.payOrder
                    let params = ["order_id": orderId, "pay_txids": transId] as [String : Any]
                    let response = AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.connectionManager.hiveHeader.headers()).responseJSON()
                    let json = try VaultApi.handlerJsonResponse(response)
                    resolver.fulfill(Receipt(json))
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func getReceipt() throws -> Promise<Receipt> {
        // TODO
        return Promise<Receipt> { resolver in
            resolver.fulfill(true as! Receipt)
        }
    }
}

public class VaultSubscription {
    public var render: SubscriptionRender
    public var context: AppContext
    public var hiveApi: HiveAPI
    
    public init (_ context: AppContext,_ userDid: String, _ providerAddress: String, _ hiveApi: HiveAPI) {
        self.context = context
        self.hiveApi = hiveApi
        self.render = SubscriptionRender(context, providerAddress, userDid)
    }

    public func subscribe(_ pricingPlan: String) throws -> Promise<VaultInfo> {
        return try self.render.subscribe(pricingPlan, VaultInfo.self);
    }
    
    public func unsubscribe() throws -> Promise<Void> {
        return try self.render.unsubscribe();
    }
    
    public func activate() throws -> Promise<Void> {
        return try self.render.activate();
    }
    
    public func deactivate() throws -> Promise<Void> {
        return try self.render.deactivate();
    }
    
    public func checkSubscription() throws -> Promise<VaultInfo> {
        return try self.render.checkSubscription();
    }
    
    
}
