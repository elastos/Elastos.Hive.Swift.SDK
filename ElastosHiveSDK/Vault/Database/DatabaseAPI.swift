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
    public func createCollection(_ collection: String, _ params: [String: Any]) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/collections/\(collection)"
        return try self.createDataRequest(url, .put, params)
    }
    
    public func deleteCollection(_ collection: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/\(collection)"
        return try self.createDataRequest(url, .delete, nil)
    }
    
    public func insert(_ collection: String, _ params: InsertParams) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/collection/\(collection)"
        return try self.createDataRequest(url, .post, params.toJSON())
    }
    
    public func update(_ collection: String, _ params: UpdateParams, _ updateone: Bool) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/collection/\(collection)?updateone=\(updateone)"
        return try self.createDataRequest(url, .patch, params.toJSON())
    }

    public func delete(_ collection: String, _ params: DeleteParams, _ deleteone: Bool) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/collection/\(collection)?deleteone=\(deleteone)"
        return try self.createDataRequest(url, .delete, params.toJSON())
    }
    
    public func count(_ collection: String, _ params: CountParams) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/collection/\(collection)?op=count"
        return try self.createDataRequest(url, .post, params.toJSON())
    }

    public func find(_ collection: String, _ filter: String, _ skip: String, _ limit: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/\(collection)?filter=\(filter)&skip=\(skip)&limit=\(limit)"
        return try self.createDataRequest(url, .get, nil)
    }
    
    public func query(_ params: QueryParams) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/query"
        return try self.createDataRequest(url, .post, params.toJSON())
    }
}
