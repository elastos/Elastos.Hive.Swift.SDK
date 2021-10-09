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
import AwaitKit

/// RemoteResolver is for accessing the code by the network and can be invalidate.
public class RemoteResolver: CodeFetcher {
    private var _serviceEndpoint: ServiceEndpoint?
    private var _backupContext: BackupContext
    private var _targetDid: String?
    private var _targetHost: String?
    
    public init(_ serviceEndpoint: ServiceEndpoint, _ backupContext: BackupContext, _ targetServiceDid: String, _ targetAddress: String) {
        _serviceEndpoint = serviceEndpoint
        _backupContext = backupContext
        _targetDid = targetServiceDid
        _targetHost = targetAddress
    }
 
    /// Fetch the code.
    /// - Returns: The code.
    public func fetch() throws -> String? {
        if _serviceEndpoint?.serviceInstanceDid == nil {
            try _serviceEndpoint?.refreshAccessToken()
        }
        
        let promise: Promise<String>? = _backupContext.getAuthorization(_serviceEndpoint?.serviceInstanceDid, _targetDid, _targetHost)
        return try `await`(promise!)
    }
    
    /// Invalidate the code for getting the code from remote server.
    public func invalidate() {}
}
