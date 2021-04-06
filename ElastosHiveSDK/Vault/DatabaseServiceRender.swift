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

public class DatabaseServiceRender: DatabaseProtocol {
    let _connectionManager: ConnectionManager
    
    public init(_ vault: Vault) {
        _connectionManager = vault.connectionManager
    }
    
    public func createCollection(_ name: String, _ options: CreateCollectionOptions?) -> Promise<Bool> {
        return Promise<Any>.async().then{ [self] _ -> Promise<Bool> in
            return Promise<Bool> { resolver in
                var param: [String: Any] = ["collection": name]
                if options != nil {
                    if try options!.jsonSerialize().count != 0 {
                        param["options"] = try options!.jsonSerialize()
                    }
                }
                let url = self._connectionManager.hiveApi.createCollection()
                let header = try self._connectionManager.headers()
                
                _ = try HiveAPi.request(url: url, method: .post, parameters: param, headers: header).get(HiveResponse.self)
                resolver.fulfill(true)
            }
        }
    }

    public func deleteCollection(_ name: String) -> Promise<Bool> {
        return Promise<Any>.async().then{ [self] _ -> Promise<Bool> in
            return Promise<Bool> { resolver in
                let param: [String: Any] = ["collection": name]
                let url = self._connectionManager.hiveApi.deleteCollection()
                let header = try self._connectionManager.headers()
                _ = try HiveAPi.request(url: url, method: .post, parameters: param, headers: header).get(HiveResponse.self)
                resolver.fulfill(true)
            }
        }
    }
    
    public func insertOne(_ collection: String, _ doc: [String : Any], _ options: InsertOptions?) -> Promise<InsertDocResponse> {
        return Promise<Any>.async().then{ [self] _ -> Promise<InsertDocResponse> in
            return Promise<InsertDocResponse> { resolver in
                var param = ["collection": collection, "document": doc] as [String : Any]
                if options != nil {
                    if try options!.jsonSerialize().count != 0 {
                        param["options"] = try options!.jsonSerialize()
                    }
                }
                let url = self._connectionManager.hiveApi.insertOne()
                let header = try self._connectionManager.headers()
                let insertOneResult = try HiveAPi.request(url: url, method: .post, parameters: param, headers: header).get(InsertDocResponse.self)
                resolver.fulfill(insertOneResult)
            }
        }
    }

    public func insertMany(_ collection: String, _ docs: Array<[String : Any]>, _ options: InsertOptions) -> Promise<InsertDocsResponse> {
        return Promise<InsertDocsResponse> { resolver in
            var param = ["collection": collection, "document": docs] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = self._connectionManager.hiveApi.insertMany()
            let header = try self._connectionManager.headers()
            let response = try HiveAPi.request(url: url, method: .post, parameters: param, headers: header).get(InsertDocsResponse.self)
            resolver.fulfill(response)
        }
    }
    
    public func countDocuments(_ collection: String, _ query: [String : Any], _ options: CountOptions) -> Promise<Int64> {
        return Promise<Any>.async().then{ [self] _ -> Promise<Int64> in
            return Promise<Int64> { resolver in
                var param = ["collection": collection, "filter": query] as [String : Any]
                if try options.jsonSerialize().count != 0 {
                    param["options"] = try options.jsonSerialize()
                }
                let url = self._connectionManager.hiveApi.countDocs()
                let header = try self._connectionManager.headers()
                let response = try HiveAPi.request(url: url, method: .post, parameters: param, headers: header).get(CountDocResponse.self)
                resolver.fulfill(response.count)
            }
        }
    }
    
    public func findOne(_ collection: String, _ query: [String : Any], _ options: FindOptions) -> Promise<FindDocResponse> {
        return Promise<Any>.async().then{ [self] _ -> Promise<FindDocResponse> in
            return Promise<FindDocResponse> { resolver in
                var param = ["collection": collection, "filter": query] as [String : Any]
                if try options.jsonSerialize().count != 0 {
                    param["options"] = try options.jsonSerialize()
                }
                let url = self._connectionManager.hiveApi.findOne()
                let header = try self._connectionManager.headers()
                let response = try HiveAPi.request(url: url, method: .post, parameters: param, headers: header).get(FindDocResponse.self)
                resolver.fulfill(response)
            }
        }
    }

    public func findMany(_ collection: String, _ query: [String : Any], _ options: FindOptions) -> Promise<FindDocsResponse> {
        return Promise<Any>.async().then{ [self] _ -> Promise<FindDocsResponse> in
            return Promise<FindDocsResponse> { resolver in
                var param = ["collection": collection, "filter": query] as [String : Any]
                if try options.jsonSerialize().count != 0 {
                    param["options"] = try options.jsonSerialize()
                }
                let url = self._connectionManager.hiveApi.findMany()
                let header = try self._connectionManager.headers()
                let response = try HiveAPi.request(url: url, method: .post, parameters: param, headers: header).get(FindDocsResponse.self)
                resolver.fulfill(response)
            }
        }
    }
    
    public func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], _ options: UpdateOptions) -> Promise<UpdateResult> {
        return Promise<Any>.async().then{ [self] _ -> Promise<UpdateResult> in

            return Promise<UpdateResult> { resolver in
                var param = ["collection": collection, "filter": filter, "update": update] as [String : Any]
                if try options.jsonSerialize().count != 0 {
                    param["options"] = try options.jsonSerialize()
                }
                let url = self._connectionManager.hiveApi.updateOne()
                let header = try self._connectionManager.headers()
                let response = try HiveAPi.request(url: url, method: .post, parameters: param, headers: header).get(UpdateDocResponse.self)
                let updateResult = UpdateResult(JSON: response.toJSON())
                resolver.fulfill(updateResult!)
            }
        }
    }

    public func updateMany(_ collection: String, _ filter: [String : Any], _ update: [String : Any], _ options: UpdateOptions) -> Promise<UpdateResult> {
        return Promise<Any>.async().then{ [self] _ -> Promise<UpdateResult> in
            return Promise<UpdateResult> { resolver in
                var param = ["collection": collection, "filter": filter, "update": update] as [String : Any]
                if try options.jsonSerialize().count != 0 {
                    param["options"] = try options.jsonSerialize()
                }
                let url = self._connectionManager.hiveApi.updateMany()
                let header = try self._connectionManager.headers()
                let response = try HiveAPi.request(url: url, method: .post, parameters: param, headers: header).get(UpdateDocResponse.self)
                let updateResult = UpdateResult(JSON: response.toJSON())
                resolver.fulfill(updateResult!)
            }
        }
    }
    
    public func deleteOne(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> Promise<DeleteResult> {
        return Promise<Any>.async().then{ [self] _ -> Promise<DeleteResult> in
            return Promise<DeleteResult> { resolver in
                var param = ["collection": collection, "filter": filter] as [String : Any]
                if try options.jsonSerialize().count != 0 {
                    param["options"] = try options.jsonSerialize()
                }
                let url = self._connectionManager.hiveApi.deleteOne()
                let header = try self._connectionManager.headers()
                let response = try HiveAPi.request(url: url, method: .post, parameters: param, headers: header).get(DeleteDocResponse.self)
                let deleteResult = DeleteResult(JSON: response.toJSON())
                resolver.fulfill(deleteResult!)
            }
        }
    }
    
    public func deleteMany(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> Promise<DeleteResult> {
        return Promise<Any>.async().then{ [self] _ -> Promise<DeleteResult> in
            return Promise<DeleteResult> { resolver in
                var param = ["collection": collection, "filter": filter] as [String : Any]
                if try options.jsonSerialize().count != 0 {
                    param["options"] = try options.jsonSerialize()
                }
                let url = self._connectionManager.hiveApi.deleteMany()
                let header = try self._connectionManager.headers()
                let response = try HiveAPi.request(url: url, method: .post, parameters: param, headers: header).get(DeleteDocResponse.self)
                let deleteResult = DeleteResult(JSON: response.toJSON())
                resolver.fulfill(deleteResult!)
            }
        }
    }
}
