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

public class DatabaseServiceRender: DatabaseProtocol {
    var vault: Vault
    
    public init(_ vault: Vault) {
        self.vault = vault
    }
    
    public func createCollection(_ name: String, options: CreateCollectionOptions?) -> Promise<Bool> {
        return Promise<Any>.async().then{ [self] _ -> Promise<Bool> in
            return createColImp(name, options)
        }
    }
    
    private func createColImp(_ collection: String, _ options: CreateCollectionOptions?) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            var param: [String: Any] = ["collection": collection]
            if options != nil {
                if try options!.jsonSerialize().count != 0 {
                    param["options"] = try options!.jsonSerialize()
                }
            }
            let url = self.vault.connectionManager.hiveApi.createCollection()
            let header = try self.vault.connectionManager.headers()
            _ = AF.request(url,
                           method: .post,
                           parameters: param,
                           encoding: JSONEncoding.default,
                           headers: header).responseJSON()
            resolver.fulfill(true)
        }
    }

    public func deleteCollection(_ name: String) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            resolver.fulfill(false)
        }
    }
    
    public func insertOne(_ collection: String, _ doc: [String : Any], options: InsertOptions?) -> Promise<InsertOneResult> {
        return Promise<Any>.async().then{ [self] _ -> Promise<InsertOneResult> in
            return insertOneImp(collection, doc, options)
        }
    }
    
    private func insertOneImp(_ collection: String, _ doc: [String: Any], _ options: InsertOptions?) -> Promise<InsertOneResult> {
        return Promise<InsertOneResult> { resolver in
            var param = ["collection": collection, "document": doc] as [String : Any]
            if options != nil {
                if try options!.jsonSerialize().count != 0 {
                    param["options"] = try options!.jsonSerialize()
                }
            }
            let url = self.vault.connectionManager.hiveApi.insertOne()
            let header = try self.vault.connectionManager.headers()
            let json = try AF.request(url,
                                          method: .post,
                                          parameters: param,
                                          encoding: JSONEncoding.default,
                                          headers: header).responseJSON().handlerJsonResponse()
            let insertOneResult = InsertOneResult(json)
            resolver.fulfill(insertOneResult)
        }
    }
    
    public func insertMany(_ collection: String, _ docs: Array<[String : Any]>, options: InsertOptions) -> Promise<InsertManyResult> {
        return Promise<Any>.async().then{ [self] _ -> Promise<InsertManyResult> in
            return insertManyImp(collection, docs, options)
        }
    }
    
    private func insertManyImp(_ collection: String, _ doc: Array<[String: Any]>, _ options: InsertOptions) -> Promise<InsertManyResult> {
        return Promise<InsertManyResult> { resolver in
            var param = ["collection": collection, "document": doc] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = self.vault.connectionManager.hiveApi.insertMany()
            let header = try self.vault.connectionManager.headers()
            let json = try AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: header).responseJSON().handlerJsonResponse()
            let insertManyResult = InsertManyResult(json)
            resolver.fulfill(insertManyResult)
        }
    }
    
    public func countDocuments(_ collection: String, _ query: [String : Any], options: CountOptions) -> Promise<Int> {
        return Promise<Any>.async().then{ [self] _ -> Promise<Int> in
            return countDocumentsImp(collection, query, options)
        }
    }
    
    private func countDocumentsImp(_ collection: String, _ query: [String: Any], _ options: CountOptions) -> Promise<Int> {
        return Promise<Int> { resolver in
            var param = ["collection": collection, "filter": query] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = self.vault.connectionManager.hiveApi.insertMany()
            let header = try self.vault.connectionManager.headers()
            let json = try AF.request(url,
                                          method: .post,
                                          parameters: param,
                                          encoding: JSONEncoding.default,
                                          headers: header).responseJSON().handlerJsonResponse()
            resolver.fulfill(json["count"].intValue)
        }
    }
    
    public func findOne(_ collection: String, _ query: [String : Any], options: FindOptions) -> Promise<[String : Any]?> {
        return Promise<Any>.async().then{ [self] _ -> Promise<[String : Any]?> in
            return findOneImp(collection, query, options)
        }
    }
    
    private func findOneImp(_ collection: String, _ query: [String: Any], _ options: FindOptions) -> Promise<[String: Any]?> {
        return Promise<[String: Any]?> { resolver in
            var param = ["collection": collection, "filter": query] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = self.vault.connectionManager.hiveApi.insertMany()
            let header = try self.vault.connectionManager.headers()
            let json = try AF.request(url,
                                      method: .post,
                                      parameters: param,
                                      encoding: JSONEncoding.default,
                                      headers: header).responseJSON().handlerJsonResponse()
            resolver.fulfill(json["items"].dictionaryObject)
        }
    }
    
    public func findMany(_ collection: String, _ query: [String : Any], options: FindOptions) -> Promise<Array<[String : Any]>?> {
        return Promise<Any>.async().then{ [self] _ -> Promise<Array<[String : Any]>?> in
            return findManyImp(collection, query, options)
        }
    }
    
    private func findManyImp(_ collection: String, _ query: [String: Any], _ options: FindOptions) -> Promise<Array<[String: Any]>?> {
        return Promise<Array<[String: Any]>?> { resolver in
            var param = ["collection": collection, "filter": query] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = self.vault.connectionManager.hiveApi.findMany()
            let header = try self.vault.connectionManager.headers()
            let json = try AF.request(url,
                                      method: .post,
                                      parameters: param,
                                      encoding: JSONEncoding.default,
                                      headers: header).responseJSON().handlerJsonResponse()
            var items: [Dictionary<String, Any>] = []
            json["items"].arrayValue.forEach { json in
                guard json.dictionaryObject == nil else {
                    items.append(json.dictionaryObject!)
                    return
                }
            }
            guard items.count == 0 else {
                resolver.fulfill(items)
                return
            }
            resolver.fulfill(nil)
        }
    }
    
    public func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions) -> Promise<UpdateResult> {
        return Promise<Any>.async().then{ [self] _ -> Promise<UpdateResult> in
            return updateOneImp(collection, filter, update, options)
        }
    }
    
    private func updateOneImp(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions) -> Promise<UpdateResult> {
        return Promise<UpdateResult> { resolver in
            var param = ["collection": collection, "filter": filter, "update": update] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = self.vault.connectionManager.hiveApi.updateOne()
            let header = try self.vault.connectionManager.headers()
            let json = try AF.request(url,
                                          method: .post,
                                          parameters: param,
                                          encoding: JSONEncoding.default,
                                          headers: header).responseJSON().handlerJsonResponse()
            let updateResult = UpdateResult(json)
            resolver.fulfill(updateResult)
        }
    }

    public func updateMany(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions) -> Promise<UpdateResult> {
        return Promise<Any>.async().then{ [self] _ -> Promise<UpdateResult> in
            return updateManyImp(collection, filter, update, options)
        }
    }
    
    private func updateManyImp(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions) -> Promise<UpdateResult>{
        return Promise<UpdateResult> { resolver in
            var param = ["collection": collection, "filter": filter, "update": update] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = self.vault.connectionManager.hiveApi.updateMany()
            let header = try self.vault.connectionManager.headers()
            let json = try! AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: header).responseJSON().handlerJsonResponse()
            let updateResult = UpdateResult(json)
            resolver.fulfill(updateResult)
        }
    }
    
    public func deleteOne(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> Promise<DeleteResult> {
        return Promise<Any>.async().then{ [self] _ -> Promise<DeleteResult> in
            return deleteOneImp(collection, filter, options)
        }
    }
    
    private func deleteOneImp(_ collection: String, _ filter: [String: Any], _ options: DeleteOptions) -> Promise<DeleteResult>{
        return Promise<DeleteResult> { resolver in
            var param = ["collection": collection, "filter": filter] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = self.vault.connectionManager.hiveApi.deleteOne()
            let header = try self.vault.connectionManager.headers()
            let json = try AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: header).responseJSON().handlerJsonResponse()
            let deleteResult = DeleteResult(json)
            resolver.fulfill(deleteResult)
        }
    }
    
    public func deleteMany(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> Promise<DeleteResult> {
        return Promise<Any>.async().then{ [self] _ -> Promise<DeleteResult> in
            return deleteManyImp(collection, filter, options)
        }
    }
    
    private func deleteManyImp(_ collection: String, _ filter: [String: Any], _ options: DeleteOptions) -> Promise<DeleteResult>{
        return Promise<DeleteResult> { resolver in
            var param = ["collection": collection, "filter": filter] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = self.vault.connectionManager.hiveApi.deleteMany()
            let header = try self.vault.connectionManager.headers()
            let json = try AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: header).responseJSON().handlerJsonResponse()
            let deleteResult = DeleteResult(json)
            resolver.fulfill(deleteResult)
        }
    }
}
