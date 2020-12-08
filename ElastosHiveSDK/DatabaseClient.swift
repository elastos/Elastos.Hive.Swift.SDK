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

public class DatabaseClient: DatabaseProtocol {
    private static let TAG = "DatabaseClient"
    private var authHelper: VaultAuthHelper
    private var vaultUrl: VaultURL

    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
        self.vaultUrl = authHelper.vaultUrl
    }
    
    public func createCollection(_ name: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.createColImp(name, nil, 0)
        }
    }

    public func createCollection(_ name: String, options: CreateCollectionOptions) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.createColImp(name, options, 0)
        }
    }

    private func createColImp(_ collection: String, _ options: CreateCollectionOptions?, _ tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            var param: [String: Any] = ["collection": collection]
            if options != nil {
                if try options!.jsonSerialize().count != 0 {
                    param["options"] = try options!.jsonSerialize()
                }
            }
            let url = vaultUrl.mongoDBSetup()
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                createColImp(collection, options, 1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }

    public func deleteCollection(_ name: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.deleteColImp(name, 0)
        }
    }

    private func deleteColImp(_ collection: String, _ tryAgain: Int) -> HivePromise<Bool> {
        return HivePromise<Bool> { resolver in
            let param = ["collection": collection]
            let url = vaultUrl.deleteMongoDBCollection()
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                deleteColImp(collection, 1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }

    public func insertOne(_ collection: String, _ doc: [String : Any], options: InsertOptions?) -> HivePromise<InsertOneResult> {
        return authHelper.checkValid().then { _ -> HivePromise<InsertOneResult> in
            return self.insertOneImp(collection, doc, options, 0)
        }
    }
    
    private func insertOneImp(_ collection: String, _ doc: [String: Any], _ options: InsertOptions?, _ tryAgain: Int) -> HivePromise<InsertOneResult> {
        HivePromise<InsertOneResult> { resolver in
            var param = ["collection": collection, "document": doc] as [String : Any]
            if options != nil {
                if try options!.jsonSerialize().count != 0 {
                    param["options"] = try options!.jsonSerialize()
                }
            }
            let url = vaultUrl.insertOne()
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                insertOneImp(collection, doc, options,1).done { oneresult in
                    resolver.fulfill(oneresult)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            let insertOneResult = InsertOneResult(json)
            resolver.fulfill(insertOneResult)
        }
    }

    public func insertMany(_ collection: String, _ docs: Array<[String : Any]>, options: InsertOptions) -> HivePromise<InsertManyResult> {
        return authHelper.checkValid().then { _ -> HivePromise<InsertManyResult> in
            return self.insertManyImp(collection, docs, options, 0)
        }
    }

    private func insertManyImp(_ collection: String, _ doc: Array<[String: Any]>, _ options: InsertOptions, _ tryAgain: Int) -> HivePromise<InsertManyResult> {
        HivePromise<InsertManyResult> { resolver in
            var param = ["collection": collection, "document": doc] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = vaultUrl.insertMany()
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                insertManyImp(collection, doc, options, 1).done { manyresult in
                    resolver.fulfill(manyresult)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            let insertManyResult = InsertManyResult(json)
            resolver.fulfill(insertManyResult)
        }
    }

    public func countDocuments(_ collection: String, _ query: [String : Any], options: CountOptions) -> HivePromise<Int> {
        return authHelper.checkValid().then { _ -> HivePromise<Int> in
            return self.countDocumentsImp(collection, query, options, 0)
        }
    }

    private func countDocumentsImp(_ collection: String, _ query: [String: Any], _ options: CountOptions, _ tryAgain: Int) -> HivePromise<Int> {
        return HivePromise<Int> { resolver in
            var param = ["collection": collection, "filter": query] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = vaultUrl.countDocuments()
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                countDocumentsImp(collection, query, options, 1).done { manyresult in
                    resolver.fulfill(manyresult)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(json["count"].intValue)
        }
    }

    public func findOne(_ collection: String, _ query: [String : Any], options: FindOptions) -> HivePromise<[String : Any]?> {
        return authHelper.checkValid().then { _ -> HivePromise<[String: Any]?> in
            return self.findOneImp(collection, query, options, 0)
        }
    }

    private func findOneImp(_ collection: String, _ query: [String: Any], _ options: FindOptions, _ tryAgain: Int) -> HivePromise<[String: Any]?> {
        return HivePromise<[String: Any]?> { resolver in
            var param = ["collection": collection, "filter": query] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = vaultUrl.findOne()
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                findOneImp(collection, query, options, 1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(json["items"].dictionaryObject)
        }
    }

    public func findMany(_ collection: String, _ query: [String : Any], options: FindOptions) -> HivePromise<Array<[String : Any]>?> {
        return authHelper.checkValid().then { _ -> HivePromise<Array<[String : Any]>?> in
            return self.findManyImp(collection, query, options, 0)
        }
    }

    private func findManyImp(_ collection: String, _ query: [String: Any], _ options: FindOptions, _ tryAgain: Int) -> HivePromise<Array<[String: Any]>?> {
        return HivePromise<Array<[String: Any]>?> { resolver in
            var param = ["collection": collection, "filter": query] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = vaultUrl.findMany()
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                findManyImp(collection, query, options, 1).done { list in
                    resolver.fulfill(list)
                }.catch { error in
                    resolver.reject(error)
                }
            }
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

    public func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions) -> HivePromise<UpdateResult> {
        return authHelper.checkValid().then { _ -> HivePromise<UpdateResult> in
            return self.updateOneImp(collection, filter, update, options, 0)
        }
    }

    private func updateOneImp(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions, _ tryAgain: Int) -> HivePromise<UpdateResult> {
        return HivePromise<UpdateResult> { resolver in
            var param = ["collection": collection, "filter": filter, "update": update] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = vaultUrl.updateOne()
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                updateOneImp(collection, filter, update, options, 1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            let updateRe = UpdateResult(json)
            resolver.fulfill(updateRe)
        }
    }

    public func updateMany(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions) -> HivePromise<UpdateResult> {
        return authHelper.checkValid().then { _ -> HivePromise<UpdateResult> in
            return self.updateManyImp(collection, filter, update, options, 0)
        }
    }

    private func updateManyImp(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions, _ tryAgain: Int) -> HivePromise<UpdateResult>{
        return HivePromise<UpdateResult> { resolver in
            var param = ["collection": collection, "filter": filter, "update": update] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = vaultUrl.updateMany()
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                updateManyImp(collection, filter, update, options, 1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            let updateRe = UpdateResult(json)
            resolver.fulfill(updateRe)
        }
    }

    public func deleteOne(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> HivePromise<DeleteResult> {
        return authHelper.checkValid().then { _ -> HivePromise<DeleteResult> in
            return self.deleteOneImp(collection, filter, options, 0)
        }
    }

    private func deleteOneImp(_ collection: String, _ filter: [String: Any], _ options: DeleteOptions, _ tryAgain: Int) -> HivePromise<DeleteResult>{
        return HivePromise<DeleteResult> { resolver in
            var param = ["collection": collection, "filter": filter] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = vaultUrl.deleteOne()
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                deleteOneImp(collection, filter, options, 1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            let deleteRe = DeleteResult(json)
            resolver.fulfill(deleteRe)
        }
    }

    public func deleteMany(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> HivePromise<DeleteResult> {
        return authHelper.checkValid().then { _ -> HivePromise<DeleteResult> in
            return self.deleteManyImp(collection, filter, options, 0)
        }
    }

    private func deleteManyImp(_ collection: String, _ filter: [String: Any], _ options: DeleteOptions, _ tryAgain: Int) -> HivePromise<DeleteResult>{
        return HivePromise<DeleteResult> { resolver in
            var param = ["collection": collection, "filter": filter] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = vaultUrl.deleteMany()
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
            if isRelogin {
                try self.authHelper.signIn()
                deleteOneImp(collection, filter, options, 1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            let deleteRe = DeleteResult(json)
            resolver.fulfill(deleteRe)
        }
    }
}
