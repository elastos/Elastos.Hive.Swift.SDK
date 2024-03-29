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

extension ConnectionManager {
    public func listChildren(_ path: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/files/\(path)?comp=children"
        return try self.createDataRequest(url, .get, nil)
    }
    
    public func getMetadata(_ path: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/files/\(path)?comp=metadata"
        return try self.createDataRequest(url, .get, nil)
    }
    
    public func getHash(_ path: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/files/\(path)?comp=hash"
        return try self.createDataRequest(url, .get, nil)
    }
    
    public func copy(_ path: String, _ dest: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/files/\(path)?dest=\(dest)"
        return try self.createDataRequest(url, .put, nil)
    }
    
    public func move(_ path: String, _ to: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/files/\(path)?to=\(to)"
        return try self.createDataRequest(url, .patch, nil)
    }
    
    public func delete(_ path: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/files/\(path)"
        return try self.createDataRequest(url, .delete, nil)
    }
}

