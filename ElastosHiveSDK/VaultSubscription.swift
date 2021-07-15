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

public class VaultSubscription: ServiceEndpoint, SubscriptionService, PaymentService {
    private var _subscriptionController: SubscriptionController!

    public override init(_ context: AppContext, _ providerAddress: String) {
        super.init(context, providerAddress)
        _subscriptionController = SubscriptionController(self)
    }
    
    public func getPricingPlanList() -> Promise<Array<PricingPlan>> {
        return Promise<Any>.async().then { [self] _ -> Promise<Array<PricingPlan>> in
            return Promise<Array<PricingPlan>> { resolver in
                do {
                    resolver.fulfill(try _subscriptionController!.getBackupPricingPlanList())
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func getPricingPlan(_ planName: String) -> Promise<PricingPlan> {
        return Promise<Any>.async().then { [self] _ -> Promise<PricingPlan> in
            return Promise<PricingPlan> { resolver in
                do {
                    resolver.fulfill(try _subscriptionController!.getBackupPricingPlan(planName))
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func subscribe() -> Promise<BackupInfo> {
        return subscribe(nil)
    }
    
    public func subscribe(_ credential: String?) -> Promise<BackupInfo> {
        return Promise<Any>.async().then { [self] _ -> Promise<BackupInfo> in
            return Promise<BackupInfo> { resolver in
                if credential != nil {
                    resolver.reject(HiveError.NotImplementedException("Paid pricing plan will be supported later"))
                }
                
                do {
                    resolver.fulfill(try _subscriptionController!.subscribeToBackup(nil))
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func unsubscribe() -> Promise<Void> {
        return Promise<Any>.async().then { [self] _ -> Promise<Void> in
            return Promise<Void> { resolver in
                do {
                    try _subscriptionController!.unsubscribeBackup()
                    resolver.fulfill(Void())
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func checkSubscription() -> Promise<BackupInfo> {
        return Promise<Any>.async().then { [self] _ -> Promise<BackupInfo> in
            return Promise<BackupInfo> { resolver in
                do {
                    resolver.fulfill(try _subscriptionController!.getBackupInfo())
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func placeOrder(_ planName: String) -> Promise<Order> {
        return Promise<Void>.async().then { _ -> Promise<Order> in
            return Promise<Order> { resolver in
                resolver.reject(HiveError.NotImplementedException("Payment will be supported later"))
            }
        }
    }
    
    public func getOrder(_ orderId: String) -> Promise<Order> {
        return Promise<Void>.async().then { _ -> Promise<Order> in
            return Promise<Order> { resolver in
                resolver.reject(HiveError.NotImplementedException("Payment will be supported later"))
            }
        }
    }
    
    public func payOrder(_ orderId: String, _ transIds: [String]) -> Promise<Receipt> {
        return Promise<Void>.async().then { _ -> Promise<Receipt> in
            return Promise<Receipt> { resolver in
                resolver.reject(HiveError.NotImplementedException("Payment will be supported later"))
            }
        }
    }
    
    public func getOrderList() -> Promise<Array<Order>> {
        return Promise<Void>.async().then { _ -> Promise<Array<Order>> in
            return Promise<Array<Order>> { resolver in
                resolver.reject(HiveError.NotImplementedException("Payment will be supported later"))
            }
        }
    }
    
    public func getReceipt(_ receiptId: String) -> Promise<Receipt> {
        return Promise<Void>.async().then { _ -> Promise<Receipt> in
            return Promise<Receipt> { resolver in
                resolver.reject(HiveError.NotImplementedException("Payment will be supported later"))
            }
        }
    }
    
    public func getReceiptList() -> Promise<Array<Receipt>> {
        return Promise<Void>.async().then { _ -> Promise<Array<Receipt>> in
            return Promise<Array<Receipt>> { resolver in
                resolver.reject(HiveError.NotImplementedException("Payment will be supported later"))
            }
        }
    }
}

