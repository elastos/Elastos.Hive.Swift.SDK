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
    private let defaultTimeout: Int = 30
    private var context: AppContext
    public var hiveApi: HiveAPi
    public var accessionToken: String?
    var tokenResolver: TokenResolver?
    
    init(_ context: AppContext) throws {
        self.context = context
        self.hiveApi = HiveAPi(self.context.providerAddress!)
    }
    
    func headersStream() -> HTTPHeaders {
        let accesstoken: String = self.accessionToken ?? ""
        return ["Content-Type": "application/octet-stream", "Authorization": "token \(accesstoken)", "Transfer-Encoding": "chunked", "Connection": "Keep-Alive"]
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
