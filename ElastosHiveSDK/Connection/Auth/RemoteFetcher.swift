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
import AwaitKit

public class RemoteFetcher: CodeFetcher {
    private var _contextProvider: AppContextProvider
    private var _controller: AuthController

    public init(_ serviceEndpoint: ServiceEndpoint) {
        _contextProvider = serviceEndpoint.appContext.appContextProvider
        _controller = AuthController(serviceEndpoint, (_contextProvider.getAppInstanceDocument())!)
    }

    /// Fetch the code.
    /// - Throws: HiveError The exception shows the error returned by hive node.
    /// - Returns: The code.
    public func fetch() throws -> String? {
        if _contextProvider.getAppInstanceDocument() == nil {
            throw HiveError.IllegalArgumentException("App instance document is nil.")
        }
        let challenge = try _controller.signIn(_contextProvider.getAppInstanceDocument()!)
        if challenge == nil {
            throw HiveError.IllegalArgumentException("Challenge is nil.")
        }
        
        let auth = try `await`(_contextProvider.getAuthorization(challenge!)!)
        return try _controller.auth(auth)
    }

    /// Invalidate the code for getting the code from remote server.
    public func invalidate() {

    }
}
