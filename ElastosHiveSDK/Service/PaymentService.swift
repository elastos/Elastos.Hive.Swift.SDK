/*
* Copyright (c) 2019 Elastos Foundation
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
 * The payment service provides users with the way to purchase a paid vault or
 * backup service, such as to subscribe to a new vault or backup with paid
 * pricing plan or extend the purchased subscription service.
 *
 */
public protocol PaymentService {
    /// Place an order for new subscription or extending the existing subscription service.
    ///
    /// - parameter planName: the name of the pricing plan
    /// - returns: return the new order detail when the request successfully was received by back-end node, otherwise return the specific exception.
    func placeOrder(_ planName: String) -> Promise<Order?>
    
    /// Obtain the order detail according to the given order id.
    ///
    /// - parameter orderId order id
    /// - returns: return the order detail in case there is a order with order id existing. otherwise, return the specific exception.
    func getOrder(_ orderId: Int) -> Promise<Order?>
    
    /// Obtain all the list of order detail.
    ///
    /// - returns: return the list of order detail on success, otherwise, return the specific exception.
    func getOrderList() -> Promise<[Order]?>
    
    /// Pay for the order with a given id.
    ///
    /// - parameters:
    ///   - orderId: order id
    ///   - transactionId: the transaction id on the block-chain.
    /// - returns: return the receipt detail in case the payment was accepted by hive node, otherwise return the specific exception.
    func settleOrder(_ orderId: Int) -> Promise<Receipt?>
    
    /// Obtain the receipt detail according to the receipt id.
    ///
    /// - parameter receiptId: receipt id.
    /// - returns: return the receipt detail in case there is a receipt existing, otherwise, return the specific exception.
    func getReceipt(_ receiptId: Int) -> Promise<Receipt?>
    
    /// Obtain the receipt of the vault.
    ///
    /// - returns: return the receipt detail in case there is a receipt existing,
    ///           otherwise, return the specific exception.
    func getReceipts() -> Promise<[Receipt]?>
    
    /// Obtain the version of the payment module.
    ///
    /// - returns: return the version, otherwise, return the specific exception.
    func getVersion() -> Promise<String?>
}
