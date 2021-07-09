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

public class PaymentController {
    private var _connectionManager: ConnectionManager
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _connectionManager = serviceEndpoint.connectionManager!
    }
    
    public func createOrder(_ subscription: String?, _ pricingPlan: String?) throws -> Order? {
        return try _connectionManager.createOrder(CreateOrderParams("", "")).execute(Order.self)
    }
    
    public func payOrder(_ orderId: String?, _ transIds: String?) throws -> Receipt? {
        return try _connectionManager.payOrder(PayOrderParams()).execute(Receipt.self)
    }
    
    public func getOrderInfo(_ orderId: String?) throws -> Order? {
        throw HiveError.NotImplementedException(nil)
    }
    
    public func getOrders(_ subscription: String?) throws -> [Order]? {
        throw HiveError.NotImplementedException(nil)
    }
    
    public func getReceipts(_ subscription: String?) throws -> [Receipt]? {
        throw HiveError.NotImplementedException(nil)
    }
    
    public func getVersion(_ subscription: String?) throws -> String? {
        throw HiveError.NotImplementedException(nil)
    }
}
