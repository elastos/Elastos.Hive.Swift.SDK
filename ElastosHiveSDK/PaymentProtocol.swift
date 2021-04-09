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

public protocol PaymentProtocol {
    
    ///  Get pricing plan list from vault & backup service, such as more storage usage, backup service support, etc.
    ///
    /// - Returns: the list of pricing plans
    func getPricingPlanList() -> Promise<Array<PricingPlan>?>
    
    /// Get a pricing plan by name. Every pricing plan has a name with which we can do the corresponding payment operation.
    ///
    /// - Parameter planName the name of the pricing plan
    /// - Returns: pricing plan
    func getPricingPlan(_ planName: String) -> Promise<PricingPlan?>

    /// Make an order for the pricing plan named with planName.
    ///
    /// - Parameter planName the name of the pricing plan
    /// - Returns: the corresponding order details.
    func placeOrder(_ orderId: String) -> Promise<Order?>
    
    
    /// Get order information by order id.
    ///
    /// - Parameter orderId order id
    /// - Returns: the corresponding order details.
    func getOrder(_ orderId: String) -> Promise<Order?>

    /// Pay for the order made before.
    ///
    /// - Parameter orderId order id
    /// - Parameter transIds payment transaction ids.
    /// - Returns: receipt details.
    func payOrder(_ orderId: String, _ transIds: [String]) -> Promise<Receipt?>

    /// Get receipt details by receipt id.
    ///
    /// - Parameter receiptId: receipt id.
    /// - Returns: receipt details.
    func getReceipt(_ receiptId: String) -> Promise<Receipt?>
}
