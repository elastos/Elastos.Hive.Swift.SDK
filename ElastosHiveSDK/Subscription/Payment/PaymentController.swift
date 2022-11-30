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

/// The payment controller is the wrapper class for accessing the payment module.
public class PaymentController {
    private var _connectionManager: ConnectionManager
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _connectionManager = serviceEndpoint.connectionManager
    }
    
    /// This is for creating the payment order which upgrades the pricing plan of the vault or the backup.
    /// - Parameters:
    ///   - subscription: The value is "vault" or "backup".
    ///   - pricingName: The pricing plan name.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The details of the order.
    public func placeOrder(_ subscription: String, _ pricingName: String) throws -> Order? {
        return try _connectionManager.placeOrder(CreateOrderParams(subscription, pricingName)).execute(Order.self)
    }

    /// Pay the order by the order id and the transaction id.
    /// - Parameters:
    ///   - orderId: The order id of payment contract
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The order which is the proof of the payment of the order for the user.
    public func settleOrder(_ orderId: Int) throws -> Receipt? {
        return try _connectionManager.settleOrder("\(orderId)").execute(Receipt.self)
    }
    
    /// Get the order information of the vault by the order id.
    /// - Parameters:
    ///   - orderId: of payment contract
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The details of the order.
    public func getVaultOrder(_ orderId: Int) throws -> Order? {
        return try getOrdersInternal("vault", "\(orderId)")?.first
    }

    /// Get the order information of the backup by the order id.
    /// - Parameter orderId: of payment contract
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The details of the order.
    public func getBackupOrder(_ orderId: Int) throws -> Order? {
        return try getOrdersInternal("backup", "\(orderId)")?.first
    }
    
    /// Get the orders by the subscription type.
    /// - Parameter subscription: The value is "vault" or "backup".
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The order list, MUST not empty.
    public func getOrders(_ subscription: String) throws -> [Order]? {
        return try getOrdersInternal(subscription, nil)
    }
    
    private func getOrdersInternal(_ subscription: String , _ orderId: String?) throws -> [Order]? {
        return try _connectionManager.getOrders(subscription, orderId).execute(OrderCollection.self).getOrders
    }
    
    /// Get the receipt by the order id.
    /// - Parameter orderId: The order id.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The details of the receipt.
    public func getReceipt(_ orderId: Int) throws -> Receipt? {
        return try getReceiptsInternal("\(orderId)")?.first
    }
    
    /// Get the receipts belongs to the current user.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The details of the receipt.
    public func getReceipts() throws -> [Receipt]? {
        return try getReceiptsInternal(nil)
    }
    
    private func getReceiptsInternal(_ orderId: String?) throws -> [Receipt]? {
        return try _connectionManager.getReceipts(orderId).execute(ReceiptCollection.self).receipts
    }
    
    /// Get the version of the payment module.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The version.
    public func getVersion() throws -> String? {
        return try _connectionManager.getVersion().execute(VersionResult.self).version
    }
}
