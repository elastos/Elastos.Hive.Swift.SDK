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
    private var _providerAddress: String
    private var _connectionManager: ConnectionManager?

    public init(_ context: AppContext, _ providerAddress: String) throws {
        self._context = context
        self._providerAddress = providerAddress
        self._connectionManager = ConnectionManager(self)
        self._connectionManager!.tokenResolver = try LocalResolver(self.appContext.userDid!,
                                                                   self.providerAddress,
                                                                   LocalResolver.TYPE_AUTH_TOKEN,
                                                                   self.appContext.appContextProvider.getLocalDataDir()!)
        let remoteResolver = RemoteResolver(self)
        try self._connectionManager!.tokenResolver?.setNextResolver(remoteResolver)
    }
    
    public var appContext: AppContext {
        return _context
    }
    
    public var userDid: String? {
        return self._context.userDid
    }
    
    public var providerAddress: String {
        return self._providerAddress
    }
        
    public var connectionManager: ConnectionManager {
        return self._connectionManager!
    }
    
    public var appDid: String? {
        return nil
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
}
