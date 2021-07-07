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

//public class VaultSubscription: ServiceEndpoint, SubscriptionProtocol, PaymentProtocol {

//    private var _context: AppContext?
//    private var _subscriptionService: SubscriptionServiceRender?
//    private var _paymentService: PaymentServiceRender?
//    
//    public override init(_ context: AppContext, _ providerAddress: String) throws {
//        try super.init(context, providerAddress)
//        self._context = context
//        self._paymentService = PaymentServiceRender(self)
//        self._subscriptionService = SubscriptionServiceRender(self)
//    }
//    
//    public func subscribe() -> Promise<VaultInfo> {
//        return Promise<VaultInfo> { resolver in
//            self._subscriptionService!.subscribe().then { _ -> Promise<VaultInfoResponse> in
//                return self._subscriptionService!.getVaultInfo()
//            }.done { response in
//                let vaultInfo = VaultInfo(nil, self.userDid, response.did)
//                vaultInfo.provider = self.providerAddress
//                vaultInfo.createTime = Date(timeIntervalSince1970: TimeInterval(integerLiteral: response.startTime))
//                vaultInfo.modifyTime =  Date(timeIntervalSince1970: TimeInterval(integerLiteral: response.modifyTime))
//                vaultInfo.maxSpace = response.maxStorage
//                vaultInfo.dbSpaceUsed = response.dbUseStorage
//                vaultInfo.fileSpaceUsed = response.fileUseStorage
//                vaultInfo.existing = response.isExisting
//                resolver.fulfill(vaultInfo)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//    
//    public func subscribe(_ credential: String) -> Promise<VaultInfo?> {
//        return Promise<Any>.async().then { _ -> Promise<VaultInfo?> in
//            return Promise<VaultInfo?> { reslover in
//                //TODO:
//                self._subscriptionService?.subscribe().done({ valutInfo in
//                    reslover.fulfill(nil)
//                }).catch({ error in
//                    reslover.reject(error)
//                })
//            }
//        }
//    }
//    
//    
//    public func unsubscribe() -> Promise<Void> {
//        return Promise<Any>.async().then { _ -> Promise<Void> in
//            return self._subscriptionService!.unsubscribe()
//        }
//    }
//    
//    public func activate() -> Promise<Void> {
//        return Promise<Any>.async().then { _ -> Promise<Void> in
//            return self._subscriptionService!.activate()
//        }
//    }
//    
//    public func deactivate() -> Promise<Void> {
//        return Promise<Any>.async().then { _ -> Promise<Void> in
//            return self._subscriptionService!.deactivate()
//        }
//    }
//    
//
//    
//    public func getPricingPlanList() -> Promise<Array<PricingPlan>?> {
//        return Promise<Void>.async().then { [self] _ -> Promise<Array<PricingPlan>?> in
//            return self._paymentService!.getPricingPlanList()
//        }
//    }
//    
//    public func getPricingPlan(_ planName: String) -> Promise<PricingPlan?> {
//        return Promise<Void>.async().then { [self] _ -> Promise<PricingPlan?> in
//            return self._paymentService!.getPricingPlan(planName)
//        }
//    }
//
//    
//    
//
//    
//    public func checkSubscription() -> Promise<VaultInfo> {
//       // TODO
//    }
//    
//    public func placeOrder(_ planName: String) -> Promise<Order?> {
//        return Promise<Any>.async().then { _ -> Promise<Order?> in
//            return Promise<Order?> { resolver in
//                resolver.reject(HiveError.NotImplementedException("Payment will be supported later"))
//            }
//        }
//    }
//
//    public func getOrder(_ orderId: String) -> Promise<Order?> {
//        return Promise<Any>.async().then { _ -> Promise<Order?> in
//            return Promise<Order?> { resolver in
//                resolver.reject(HiveError.NotImplementedException("Payment will be supported later"))
//            }
//        }
//    }
//    
//    public func payOrder(_ orderId: String, _ transactionId: [String]) -> Promise<Receipt?> {
//        return Promise<Any>.async().then { _ -> Promise<Receipt?> in
//            return Promise<Receipt?> { resolver in
//                resolver.reject(HiveError.NotImplementedException("Payment will be supported later"))
//            }
//        }
//    }
//    
//    public func getOrderList() -> Promise<Array<Order>?> {
//        return Promise<Any>.async().then { _ -> Promise<Array<Order>?> in
//            return Promise<Array<Order>?> { resolver in
//                resolver.reject(HiveError.NotImplementedException("Payment will be supported later"))
//            }
//        }
//    }
//    
//    public func getReceipt(_ receiptId: String) -> Promise<Receipt?> {
//        return Promise<Any>.async().then { _ -> Promise<Receipt?> in
//            return Promise<Receipt?> { resolver in
//                resolver.reject(HiveError.NotImplementedException("Payment will be supported later"))
//            }
//        }
//    }
//    
//    public func getReceiptList() -> Promise<Array<Receipt>?> {
//        return Promise<Any>.async().then { _ -> Promise<Array<Receipt>?> in
//            return Promise<Array<Receipt>?> { resolver in
//                resolver.reject(HiveError.NotImplementedException("Payment will be supported later"))
//            }
//        }
//    }
//}

