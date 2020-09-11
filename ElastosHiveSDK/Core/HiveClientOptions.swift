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

@objc(HiveClientOptions)
public class HiveClientOptions: NSObject {
//    private var _storePath: String?
//    private var _authenticator: Authenticator?
    private var _enableCloudSync: Bool?
    private var _authenticator: Authenticator?
    private var _authenticationDIDDocument: DIDDocument?
    private var _DIDResolverUrl: String?
    private var _localPath: String?

    public override init() {
        super.init()
    }

    public var didResolverUrl: String? {
        get {
            return _DIDResolverUrl
        }
    }

    public func setDidResolverUrl(_ DIDResolverUrl: String) {
        self._DIDResolverUrl = DIDResolverUrl
    }

    public var enableCloudSync: Bool {
        get {
            return _enableCloudSync!
        }
    }

    public func setEnableCloudSync(_ enable: Bool) {
        self._enableCloudSync = enable
    }

    public var authenticationDIDDocument: DIDDocument {
        get {
            return _authenticationDIDDocument!
        }
    }

    public func setAuthenticationDIDDocument(_ document: DIDDocument) -> HiveClientOptions {
        self._authenticationDIDDocument = document
        return self
    }

    public var authenicator: Authenticator? {
        get {
            return _authenticator
        }
    }

    public func setAuthenticator(_ authenticator: Authenticator) -> HiveClientOptions {
        self._authenticator = authenticator

        return self
    }

    public var localPath: String {
        get {
            return _localPath!
        }
    }

    public func setLocalDataPath(_ path: String) -> HiveClientOptions {
        self._localPath = path

        return self
    }

    func buildClient() -> HiveClientHandle? {
        return nil
    }

    func checkValid(_ all: Bool) -> Bool {
        return _localPath != nil && (!all || _authenticator != nil)
    }
}
