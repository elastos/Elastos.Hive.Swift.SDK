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
import ObjectMapper

public class RemoteResolver: TokenResolver {
    private var _contextProvider: AppContextProvider
    private var _authenticationServiceRender: AuthenticationServiceRender
    
    public init (_ serviceEndpoint: ServiceEndpoint) {
        self._contextProvider = serviceEndpoint.appContext.appContextProvider
        self._authenticationServiceRender = AuthenticationServiceRender(serviceEndpoint)
    }


    public func getToken() throws -> AuthToken? {
        return try self._authenticationServiceRender.auth(token: self._authenticationServiceRender.signInForToken())
    }

    public func invlidateToken() throws {
        throw HiveError.UnsupportedOperationException
    }

    public func setNextResolver(_ resolver: TokenResolver?) throws {
        throw HiveError.UnsupportedOperationException
    }
}
