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
public protocol PaymentProtocol {
    
    ///  Let users to get the all the pricing plan list in order to subscribe to a new vault or backup
    ///   service on the user's requirement.
    ///
    /// - returns: Return a list of all pricing plan with specific type on success. Otherwise, the specific exception would be returned.
    func getPricingPlanList() -> Promise<Array<PricingPlan>?>
    
    /// Let users to get the specific pricing plan information.
    ///
    /// - parameter planName: the name of the pricing plan
    /// - returns: Return the specific pricing plan information on success. Otherwise, the specific exception would be returned.
    func getPricingPlan(_ planName: String) -> Promise<PricingPlan?>
    
    
    /// Make an order for the pricing plan named with planName.
    ///
    /// - parameter planName: the corresponding order details.
    /// - returns: the corresponding order details.
    func placeOrder(_ planName: String) -> Promise<Order?>
    
    /// Get order information by order id.
    ///
    /// - parameter orderId order id
    /// - returns: the corresponding order details.
    func getOrder(_ orderId: String) -> Promise<Order?>

    /// Pay for the order made before.
    ///
    /// - parameters:
    ///   - orderId: order id
    ///   - transIds: payment transaction ids.
    /// - returns: receipt details.
    func payOrder(_ orderId: String, _ transIds: [String]) -> Promise<Receipt?>

    /// Get receipt details by receipt id.
    ///
    /// - parameter receiptId: receipt id.
    /// - returns: receipt details.
    func getReceipt(_ receiptId: String) -> Promise<Receipt?>
}
