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
import ObjectMapper

public class LocalResolver: CodeFetcher {
    private var _serviceEndpoint: ServiceEndpoint?
    private var _nextResolver: CodeFetcher?
    
    public init(_ serviceEndpoint: ServiceEndpoint, _ next: CodeFetcher) {
        _serviceEndpoint = serviceEndpoint
        _nextResolver = next
    }
    
    public func fetch() throws -> String? {
        var token: String? = restoreToken()
        if token == nil {
            token = try _nextResolver?.fetch()
            saveToken(token!)
        }
        
        return token
    }
    
    public func invalidate() {
        clearToken()
    }
    
    private func restoreToken() -> String? {
        let storage: DataStorage = _serviceEndpoint!.getStorage()

        if _serviceEndpoint?.serviceInstanceDid == nil {
            return nil
        }

        return storage.loadBackupCredential(_serviceEndpoint!.serviceInstanceDid!)
    }
    
    private func saveToken(_ token: String) {
        let storage: DataStorage = _serviceEndpoint!.getStorage()
        
        if _serviceEndpoint?.serviceInstanceDid != nil {
            storage.storeBackupCredential(_serviceEndpoint!.serviceInstanceDid!, token)
        }
    }
    
    private func clearToken() {
        let storage: DataStorage = (_serviceEndpoint?.getStorage())!
        
        if _serviceEndpoint?.serviceInstanceDid != nil {
            storage.clearBackupCredential((_serviceEndpoint?.serviceInstanceDid)!)
        }
    }
}

