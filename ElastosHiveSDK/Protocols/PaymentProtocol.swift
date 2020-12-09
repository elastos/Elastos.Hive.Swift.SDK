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

    /// Get vault's payment info
    /// PricingPlan list
    func getPaymentInfo() -> Promise<PricingInfo>

    /// Get vault pricing plan information by plan name
    /// - Parameter planName: planName plan name
    /// Return: the instance of PricingPlan
    func getPricingPlan(_ planName: String) -> Promise<PricingPlan>
    
    /// Get payment version
    func getPaymentVersion() -> Promise<String>

    /// Create a order of pricing plan
    /// - Parameter priceName: priceName
    func placeOrder(_ priceName: String) -> Promise<String>

    /// Pay for  pricing plan order
    /// - Parameters:
    ///   - orderId: orderId
    ///   - txids: txids
    func payOrder(_ orderId: String, _ txids: Array<String>) -> Promise<Bool>

    /// Get order information of vault service purchase
    /// - Parameter orderId: orderId
    func getOrder(_ orderId: String) -> Promise<Order>

    /// Get user order information list of vault service purchase
    func getAllOrders() -> Promise<Array<Order>>
    
    /// Get using price plan
    func getUsingPricePlan() -> Promise<UsingPlan>
}
