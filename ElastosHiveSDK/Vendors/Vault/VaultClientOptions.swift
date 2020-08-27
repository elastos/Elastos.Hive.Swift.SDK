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

class VaultClientOptions: HiveClientOptions {
    private var _authToken: String?
    private var _clientId: String?
    private var _clientSecret: String?
    private var _redirectURL: String?
    private var _nodeUrl: String?

    override init() { }

    func setAuthToken(_ authToken: String) {
        _authToken = authToken
    }

    public var authToken: String {
        get {
            return _authToken!
        }
    }

    func setClientId(_ clientId: String) {
        _clientId = clientId
    }

    public var clientId: String {
        get {
            return _clientId!
        }
    }

    func setClientSecret(_ clientSecret: String) {
        _clientSecret = clientSecret
    }

    public var clientSecret: String {
        get {
            return _clientSecret!
        }
    }

    func setRedirectURL(_ redirectURL: String) {
        _redirectURL = redirectURL
    }

    public var redirectURL: String {
        get {
            return _redirectURL!
        }
    }

    func setNodeUrl(_ url: String) {
        _nodeUrl = url
    }

    public var nodeUrl: String {
        get {
            return _nodeUrl!
        }
    }

    override func checkValid(_ all: Bool) -> Bool {

        return _clientId != nil && _redirectURL != nil && super.checkValid(all)
    }

    func checkValid() -> Bool {
        return checkValid(true)
    }

    override func buildClient() -> HiveClientHandle? {
        return VaultClientHandle(self)
    }
}
