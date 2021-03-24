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

public class ServiceEndpoint {
    private var _context: AppContext
    var _providerAddress: String?
    var _userDid: String?
    var _targetDid: String?
    
    var _targetAppDid: String?
    
    /// This constructor will be embedded in the following global-grained extends:
    public convenience init(_ context: AppContext, _ providerAddress: String?, _ userDid: String) {
        self.init(context, providerAddress, userDid, userDid, nil)
    }
    
    /// This constructor will be embedded in the following service-grained extends:
    public init(_ context: AppContext, _ providerAddress: String?, _ userDid: String, _ targetDid: String?, _ targetAppDid: String?) {
        self._context = context
        self._providerAddress = providerAddress
        self._userDid = userDid
        self._targetDid = targetDid
        self._targetAppDid = targetAppDid
    }
    
    public var providerAddress: String {
        return _providerAddress!
    }

    public var endpointAddress: String {
        return _providerAddress!
    }
    
    public var appDid: String? {
        return _targetAppDid
    }
    
    public var ownerDid: String? {
        return _targetDid
    }
    
    public var userDid: String {
        return _userDid!
    }
    
    public var appInstanceDid: String? {
        return nil
    }
    
    public var serviceDid: String? {
        return nil
    }
    
    public var serviceInstanceDid: String? {
        return nil
    }
    
    public var connectionManager: ConnectionManager {
        return self._context.connectionManager
    }
    
    public var context: AppContext {
        return _context
    }
}
