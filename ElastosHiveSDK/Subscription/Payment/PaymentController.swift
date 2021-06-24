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
    
    public init () {
        
    }
    
    public func createOrder(_ subscription: String, _ pricingPlan: String) -> Order {
//
//        HiveAPi.request(url: HiveAPi.createOrder(<#T##self: HiveAPi##HiveAPi#>), method: <#T##HTTPMethod#>, parameters: <#T##Parameters?#>, headers: <#T##HTTPHeaders?#>)
//
        
//        return Promise<Void>.async().then { [self] _ -> Promise<String?> in
//            return Promise<String?> { resolver in
//                do {
//                    let params = ["pricing_name": planName, "backing_name": ""]
//                    let response: HiveResponse = try HiveAPi.request(url: self._serviceEndpoint.connectionManager.hiveApi.createOrder(),
//                                                                     method: .post,
//                                                                     parameters: params as Parameters,
//                                                                     headers: try self._serviceEndpoint.connectionManager.headers()).get(HiveResponse.self)
//                    resolver.fulfill((response.json["order_id"] as! String))
//                } catch {
//                    resolver.reject(error)
//                }
//            }
//        }
    }
}
