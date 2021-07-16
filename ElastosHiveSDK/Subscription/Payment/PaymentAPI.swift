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

extension ConnectionManager {
    public func createOrder(_ params: CreateOrderParams) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/payment/order"
        return try self.createDataRequest(url, .put, params.toJSON())
    }
    
    public func payOrder(_ params: PayOrderParams) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/payment/order/{order_id}"
        return try self.createDataRequest(url, .post, params.toJSON())
    }
    
    public func getOrders(_ subscription: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/payment/order?subscription=\(subscription)"
        return try self.createDataRequest(url, .get, nil)
    }

//    public func getReceipts(_ subscription: String) throws -> DataRequest {
//        let url = self.baseURL + "/api/v2/payment/receipt?subscription=\(subscription)"
//        return try self.createDataRequest(url, .get, nil)
//    }
    
    public func getReceipt(_ orderId: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/payment/receipt?order_id=\(orderId)"
        return try self.createDataRequest(url, .get, nil)
    }
    
    public func getVersion() throws -> DataRequest {
        let url = self.baseURL + "/api/v2/payment/version"
        return try self.createDataRequest(url, .get, nil)
    }
}
