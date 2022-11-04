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

/// The vault subscription is used for the vault management.
/// Subscribe the vault is the first step to use the service in the vault.
public class VaultSubscription: ServiceEndpoint, SubscriptionService, PaymentService {
    private var _subscriptionController: SubscriptionController!
    private var _paymentController: PaymentController?
    
    public override init(_ context: AppContext) throws {
        try super.init(context)
        _subscriptionController = SubscriptionController(self)
        _paymentController = PaymentController(self)
    }
    
    /// Create by the application context, and the address of the provider.
    ///
    /// - parameters:
    ///   - context: The application context.
    ///   - providerAddress: The address of the provider.
    /// - throws: HiveException
    public override init(_ context: AppContext, _ providerAddress: String) throws {
        try super.init(context, providerAddress)
        _subscriptionController = SubscriptionController(self)
        _paymentController = PaymentController(self)
    }
    
    /// Let users to get the all the pricing plan list in order to subscribe to a new vault or backup service on the user's requirement.
    ///
    /// - returns: Return a list of all pricing plan with specific type on success. Otherwise, the specific exception would be returned.
    public func getPricingPlanList() -> Promise<Array<PricingPlan>> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _subscriptionController!.getBackupPricingPlanList()
        }
    }
    
    /// Let users to get the specific pricing plan information.
    ///
    /// - parameter planName: the name of the pricing plan
    /// - returns: Return a list of all pricing plan with specific type on success. Otherwise, the specific exception would be returned.
    public func getPricingPlan(_ planName: String) -> Promise<PricingPlan> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _subscriptionController!.getVaultPricingPlan(planName)
        }
    }
    
    /// Let a new user subscribe to the entity service on the specified back-end node, where the entity service would be vault or backup service. Currently this method would only support for subscription to a entity service with free pricing plan. When there is already a corresponding service existed, no new service would be subscribed or created.
    ///
    /// - returns: The basic information of the newly created or existing vault on success, otherwise, the specific exception would returned in the wrapper.
    public func subscribe() -> Promise<VaultInfo> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _subscriptionController!.subscribeToVault()
        }
    }
    
    /// Let user to unsubscribe to an existing but useless vault or backup service.
    ///
    /// - Returns: None would be returned on success, otherwise, the specific exception would be returned.
    public func unsubscribe() -> Promise<Void> {
        return unsubscribe(false)
    }
    
    public func unsubscribe(_ force: Bool) -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _subscriptionController!.unsubscribeVault(force)
        }
    }
    
    
    public func activate() throws -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _subscriptionController!.activateVault()
        }
    }
    
    public func deactivate() throws -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _subscriptionController!.deactivateVault()
        }
    }
    
    public func activate() throws -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _subscriptionController!.activateVault()
        }
    }
    
    public func deactivate() throws -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _subscriptionController!.deactivateVault()
        }
    }
    
    /// Let the user to get the basic information of the subscription.
    ///
    /// - Returns: The basic information of the newly created or existing vault on success, otherwise, the specific exception would returned in the wrapper.
    public func checkSubscription() -> Promise<VaultInfo> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _subscriptionController!.getVaultInfo()
        }
    }
    
    public func getAppStats() -> Promise<[AppInfo]?> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _subscriptionController!.getAppStats()
        }
    }
    
    /// Place an order for new subscription or extending the existing subscription service.
    ///
    /// - parameter planName: the name of the pricing plan
    /// - returns: return the new order detail when the request successfully was received by back-end node, otherwise return the specific exception.
    public func placeOrder(_ planName: String) -> Promise<Order?> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _paymentController?.placeOrder("vault", planName)
        }
    }
    
    /// Obtain the order detail according to the given order id.
    ///
    /// - parameter orderId order id
    /// - returns: return the order detail in case there is a order with order id existing. otherwise, return the specific exception.
    public func getOrder(_ orderId: Int) -> Promise<Order?> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _paymentController?.getVaultOrder(orderId)
        }
    }
    
    /// Pay for the order with a given id.
    ///
    /// - parameters:
    ///   - orderId: order id
    ///   - transactionId: the transaction id on the block-chain.
    /// - returns: return the receipt detail in case the payment was accepted by hive node, otherwise return the specific exception.
    public func settleOrder(_ orderId: Int) -> Promise<Receipt?> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _paymentController?.settleOrder(orderId)
        }
    }
    
    /// Obtain all the list of order detail.
    ///
    /// - returns: return the list of order detail on success, otherwise, return the specific exception.
    public func getOrderList() -> Promise<[Order]?> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _paymentController?.getOrders("vault")
        }
    }
    
    /// Obtain the receipt detail according to the receipt id.
    ///
    /// - parameter receiptId: receipt id.
    /// - returns: return the receipt detail in case there is a receipt existing, otherwise, return the specific exception.
    public func getReceipt(_ orderId: Int) -> Promise<Receipt?> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _paymentController?.getReceipt(orderId)
        }
    }
    
    /// Obtain the receipt of the vault.
    ///
    /// - returns: the receipt detail in case there is a receipt existing,
    /// otherwise, return the specific exception.
    public func getReceipts() -> Promise<[Receipt]?> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _paymentController?.getReceipts()
        }
    }

    /// Obtain the version of the payment module.
    ///
    /// - returns: return the version, otherwise, return the specific exception.
    public func getVersion() -> Promise<String?> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _paymentController!.getVersion()
        }
    }
}

