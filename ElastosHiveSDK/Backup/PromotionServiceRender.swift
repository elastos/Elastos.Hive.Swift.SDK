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

public class PromotionServiceRender: PromotionProtocol {
    
    private var _serviceEndpoint: ServiceEndpoint
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        self._serviceEndpoint = serviceEndpoint
    }
    
    public func promote() -> Promise<Void> {
        return Promise<Any>.async().then{ [self] _ -> Promise<Void> in
            return Promise<Void> { resolver in
                let url = self._serviceEndpoint.connectionManager.hiveApi.activeToVault()
                let header = try self._serviceEndpoint.connectionManager.headers()
                _ = try HiveAPi.request(url: url, method: .post, parameters: nil, headers: header).get(HiveResponse.self)
                resolver.fulfill(Void())
            }
            
        }
    }
}
