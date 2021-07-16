/*
 * Copyright (c) 2021 Elastos Foundation
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

public class BackupSubscription: ServiceEndpoint, SubscriptionService, PaymentService {    
    private var _subscriptionController: SubscriptionController?
    private var _paymentController: PaymentController?

    public override init(_ context: AppContext, _ providerAddress: String) {
        super.init(context, providerAddress)
        _subscriptionController = SubscriptionController(self)
        _paymentController = PaymentController(self)
    }
    
    public func getPricingPlanList() -> Promise<Array<PricingPlan>> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _subscriptionController!.getBackupPricingPlanList()
        }
    }
    
    public func getPricingPlan(_ planName: String) -> Promise<PricingPlan> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _subscriptionController!.getBackupPricingPlan(planName)
        }
    }
    
    public func subscribe() -> Promise<BackupInfo> {
        return subscribe(nil)
    }
    
    public func subscribe(_ credential: String?) -> Promise<BackupInfo> {
        return DispatchQueue.global().async(.promise){ [self] in
            if credential != nil {
                throw HiveError.NotImplementedException("Paid pricing plan will be supported later")
            }
            return try _subscriptionController!.subscribeToBackup(nil)
        }
    }
    
    public func unsubscribe() -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _subscriptionController!.unsubscribeBackup()
        }
    }
    
    public func checkSubscription() -> Promise<BackupInfo> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _subscriptionController!.getBackupInfo()
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
    
    public func payOrder(_ orderId: String, _ transIds: String) -> Promise<Receipt> {
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
    
//    public func getReceiptList() -> Promise<Array<Receipt>> {
//        return Promise<Void>.async().then { _ -> Promise<Array<Receipt>> in
//            return Promise<Array<Receipt>> { resolver in
//                resolver.reject(HiveError.NotImplementedException("Payment will be supported later"))
//            }
//        }
//    }

    public func getVersion() -> Promise<String?> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _paymentController!.getVersion()
        }
    }
}
