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

class VaultClientOptionsBuilder: NSObject {
    private var options: VaultClientOptions?

    public override init() {
        options = VaultClientOptions()
        super.init()
    }

    public func withClientId(_ clientId: String) -> VaultClientOptionsBuilder {
        options?.setClientId(clientId)
        return self
    }

    public func withRedirectUrl(_ redirectUrl: String) -> VaultClientOptionsBuilder {
        options?.setRedirectURL(redirectUrl)
        return self
    }

    public func withNodeUrl(_ nodeUrl: String) -> VaultClientOptionsBuilder {
        options?.setNodeUrl(nodeUrl)
        return self
    }

    public func withAuthToken(_ authToken: String) -> VaultClientOptionsBuilder {
        options?.setAuthToken(authToken)
        return self
    }

    public func withClientSecret(_ clientSecret: String) -> VaultClientOptionsBuilder {
        options?.setClientSecret(clientSecret)
        return self
    }

    public func withAuthenticator(_ authenticator: Authenticator) -> VaultClientOptionsBuilder {
        _ = options?.setAuthenticator(authenticator)
        return self
    }

    public func withStorePath(using path: String) -> VaultClientOptionsBuilder {
        _ = options?.setLocalDataPath(path)
        return self
    }

    public func build() throws -> VaultClientOptions {
        guard let _ = options else {
            throw HiveError.invalidatedBuilder(des: "Invalidated builder")
        }

        guard options!.checkValid() else {
            throw HiveError.insufficientParameters(des: "Imcomplete options fields")
        }

        let _options = self.options!
        self.options = nil
        return _options
    }
}
