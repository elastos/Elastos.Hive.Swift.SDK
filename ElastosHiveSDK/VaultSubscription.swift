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
    public var userDid: String?
    public var appInstanceDid: String?
    public var appId: String?
    public var provider: String?
    public var serviceDid: String?
    public var pricingUsing: String?
    public var createTime: Date?
    public var modifyTime: Date?
    public var maxSpace: Int64?
    public var dbSpaceUsed: Int64?
    public var fileSpaceUsed: Int64?
    public var existing: Bool = false
    
    public init(_ appInstanceDid: String?, _ userDid: String?, _ serviceDid: String) {
        self.appInstanceDid = appInstanceDid
        self.userDid = userDid
        self.serviceDid = serviceDid
    }
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        
    }
}

public class VaultSubscription: ServiceEndpoint, SubscriptionProtocol, PaymentProtocol {
    private var _context: AppContext?
    private var _subscriptionService: SubscriptionServiceRender?
    private var _paymentService: PaymentServiceRender?
    
    public override init(_ context: AppContext, _ providerAddress: String) throws {
        try super.init(context, providerAddress)
        self._context = context
        self._paymentService = PaymentServiceRender(self)
        self._subscriptionService = SubscriptionServiceRender(self)
    }
    
    public func subscribe() -> Promise<VaultInfo> {
        return Promise<VaultInfo> { resolver in
            self._subscriptionService!.subscribe().then { _ -> Promise<VaultInfoResponse> in
                return self._subscriptionService!.getVaultInfo()
            }.done { response in
                let vaultInfo = VaultInfo(nil, self.userDid, response.did)
                vaultInfo.provider = self.providerAddress
                vaultInfo.createTime = Date(timeIntervalSince1970: TimeInterval(integerLiteral: response.startTime))
                vaultInfo.modifyTime =  Date(timeIntervalSince1970: TimeInterval(integerLiteral: response.modifyTime))
                vaultInfo.maxSpace = response.maxStorage
                vaultInfo.dbSpaceUsed = response.dbUseStorage
                vaultInfo.fileSpaceUsed = response.fileUseStorage
                vaultInfo.existing = response.isExisting
                resolver.fulfill(vaultInfo)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    public func unsubscribe() -> Promise<Void> {
        return Promise<Any>.async().then { _ -> Promise<Void> in
            return self._subscriptionService!.unsubscribe()
        }
    }
    
    public func activate() -> Promise<Void> {
        return Promise<Any>.async().then { _ -> Promise<Void> in
            return self._subscriptionService!.activate()
        }
    }
    
    public func deactivate() -> Promise<Void> {
        return Promise<Any>.async().then { _ -> Promise<Void> in
            return self._subscriptionService!.deactivate()
        }
    }
    
    public func checkSubscription() -> Promise<VaultInfo> {
        return Promise<Any>.async().then { _ -> Promise<VaultInfo> in
            return Promise<VaultInfo> { resolver in
                self._subscriptionService!.getVaultInfo().done { response in
                    let vaultInfo = VaultInfo(nil, self.userDid, response.did)
                    vaultInfo.provider = self.providerAddress
                    vaultInfo.createTime = Date(timeIntervalSince1970: TimeInterval(integerLiteral: response.startTime))
                    vaultInfo.modifyTime =  Date(timeIntervalSince1970: TimeInterval(integerLiteral: response.modifyTime))
                    vaultInfo.maxSpace = response.maxStorage
                    vaultInfo.dbSpaceUsed = response.dbUseStorage
                    vaultInfo.fileSpaceUsed = response.fileUseStorage
                    vaultInfo.existing = response.isExisting
                    resolver.fulfill(vaultInfo)
                }.catch { error in
                    resolver.reject(error)

                }
            }
        }
    }
    
    public func getPricingPlanList() -> Promise<Array<PricingPlan>?> {
        return Promise<Void>.async().then { [self] _ -> Promise<Array<PricingPlan>?> in
            return self._paymentService!.getPricingPlanList()
        }
    }
    
    public func getPricingPlan(_ planName: String) -> Promise<PricingPlan?> {
        return Promise<Void>.async().then { [self] _ -> Promise<PricingPlan?> in
            return self._paymentService!.getPricingPlan(planName)
        }
    }
    
    public func placeOrder(_ planName: String) -> Promise<Order?> {
        return Promise<Void>.async().then { [self] _ -> Promise<Order?> in
            return Promise<Order?> { resolver in
                self._paymentService!.createPricingOrder(planName).then({ orderId -> Promise<Order?> in
                    return self._paymentService!.getOrderInfo(orderId!)
                }).done { order in
                    resolver.fulfill(order)
                }.catch { error in
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func getOrder(_ orderId: String) -> Promise<Order?> {
        return Promise<Void>.async().then { [self] _ -> Promise<Order?> in
            return self._paymentService!.getOrderInfo(orderId)
        }
    }
    
    public func payOrder(_ orderId: String, _ transIds: [String]) -> Promise<Receipt?> {
        return Promise<Void>.async().then { [self] _ -> Promise<Receipt?> in
            return self._paymentService!.payOrder(orderId, transIds)
        }
    }
    
    public func getReceipt(_ receiptId: String) -> Promise<Receipt?> {
        return Promise<Receipt?> { resolver in
            resolver.reject(HiveError.UnsupportedOperationException)
        }
    }
}

