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

public class ConnectionManager {
    
    private var _serviceEndpoint: ServiceEndpoint
    private let defaultTimeout: Int = 30
    public var hiveApi: HiveAPi
    public var accessionToken: String?
    public var tokenResolver: TokenResolver?
    
    
    init(_ serviceEndpoint: ServiceEndpoint) {
        self._serviceEndpoint = serviceEndpoint
        self.hiveApi = HiveAPi(self._serviceEndpoint.providerAddress)
    }
    
    func headersStream() throws -> HTTPHeaders {
        let token = try self.tokenResolver!.getToken()!.accessToken
        self.accessionToken = token
        return ["Content-Type": "application/octet-stream", "Authorization": "token \(token)", "Transfer-Encoding": "chunked", "Connection": "Keep-Alive"]
    }
    
    func headers() throws -> HTTPHeaders {
        let token = try self.tokenResolver!.getToken()!.accessToken
        self.accessionToken = token
        return ["Content-Type": "application/json;charset=UTF-8", "Authorization": "token \(token)"]
    }
    
    func NormalHeaders() -> HTTPHeaders {
        return ["Content-Type": "application/json;charset=UTF-8"]
    }
}
