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

    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }
    
    public func createCollection(_ name: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.createColImp(name, nil, tryAgain: 0)
        }
    }

    public func createCollection(_ name: String, options: CreateCollectionOptions) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.createColImp(name, options, tryAgain: 0)
        }
    }

    private func createColImp(_ collection: String, _ options: CreateCollectionOptions?, tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            var param: [String: Any] = ["collection": collection]
            if options != nil {
                if try options!.jsonSerialize().count != 0 {
                    param["options"] = try options!.jsonSerialize()
                }
            }
            let header = Header(authHelper)
            let url = VaultURL.sharedInstance.mongoDBSetup()
            
            VaultApi.request(url: url, parameters: param, headers: header.headers()).done { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<Bool> in
                            return self.createColImp(collection, options, tryAgain: 1)
                        }.done { success in
                            resolver.fulfill(true)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(DatabaseClient.TAG, "createCollection ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    resolver.fulfill(true)
                }
            }.catch { error in
                Log.e(DatabaseClient.TAG, "createCollection ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func deleteCollection(_ name: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.deleteColImp(name, tryAgain: 0)
        }
    }

    private func deleteColImp(_ collection: String, tryAgain: Int) -> HivePromise<Bool> {
        return HivePromise<Bool> { resolver in
            let param = ["collection": collection]
            let header = Header(authHelper)
            let url = VaultURL.sharedInstance.deleteMongoDBCollection()
            
            VaultApi.request(url: url, parameters: param, headers: header.headers()).done { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<Bool> in
                            return self.deleteColImp(collection, tryAgain: 1)
                        }.done { success in
                            resolver.fulfill(true)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(DatabaseClient.TAG, "deleteCollection ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    resolver.fulfill(true)
                }
            }.catch { error in
                Log.e(DatabaseClient.TAG, "deleteCollection ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func insertOne(_ collection: String, _ doc: [String : Any], options: InsertOptions?) -> HivePromise<InsertOneResult> {
        return authHelper.checkValid().then { _ -> HivePromise<InsertOneResult> in
            return self.insertOneImp(collection, doc, options, tryAgain: 0)
        }
    }
    
    private func insertOneImp(_ collection: String, _ doc: [String: Any], _ options: InsertOptions?, tryAgain: Int) -> HivePromise<InsertOneResult> {
        HivePromise<InsertOneResult> { resolver in
            var param = ["collection": collection, "document": doc] as [String : Any]
            if options != nil {
                if try options!.jsonSerialize().count != 0 {
                    param["options"] = try options!.jsonSerialize()
                }
            }
            let url = VaultURL.sharedInstance.insertOne()
            
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<InsertOneResult> in
                            return self.insertOneImp(collection, doc, options, tryAgain: 1)
                        }.done { insertResult in
                            resolver.fulfill(insertResult)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(DatabaseClient.TAG, "insertOne ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    let insertOneResult = InsertOneResult(json)
                    resolver.fulfill(insertOneResult)
                }
            }.catch { error in
                Log.e(DatabaseClient.TAG, "insertOne ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func insertMany(_ collection: String, _ docs: Array<[String : Any]>, options: InsertOptions) -> HivePromise<InsertManyResult> {
        return authHelper.checkValid().then { _ -> HivePromise<InsertManyResult> in
            return self.insertManyImp(collection, docs, options, tryAgain: 0)
        }
    }

    private func insertManyImp(_ collection: String, _ doc: Array<[String: Any]>, _ options: InsertOptions, tryAgain: Int) -> HivePromise<InsertManyResult> {
        HivePromise<InsertManyResult> { resolver in
            var param = ["collection": collection, "document": doc] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = VaultURL.sharedInstance.insertMany()
            
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<InsertManyResult> in
                            return self.insertManyImp(collection, doc, options, tryAgain: 1)
                        }.done { insertResult in
                            resolver.fulfill(insertResult)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(DatabaseClient.TAG, "insertMany ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    let insertManyResult = InsertManyResult(json)
                    resolver.fulfill(insertManyResult)
                }
            }.catch { error in
                Log.e(DatabaseClient.TAG, "insertMany ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func countDocuments(_ collection: String, _ query: [String : Any], options: CountOptions) -> HivePromise<Int> {
        return authHelper.checkValid().then { _ -> HivePromise<Int> in
            return self.countDocumentsImp(collection, query, options, tryAgain: 0)
        }
    }

    private func countDocumentsImp(_ collection: String, _ query: [String: Any], _ options: CountOptions, tryAgain: Int) -> HivePromise<Int> {
        return HivePromise<Int> { resolver in
            var param = ["collection": collection, "filter": query] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = VaultURL.sharedInstance.countDocuments()

            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<Int> in
                            return self.countDocumentsImp(collection, query, options, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(DatabaseClient.TAG, "countDocuments ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    resolver.fulfill(json["count"].intValue)
                }
            }.catch { error in
                Log.e(DatabaseClient.TAG, "countDocuments ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func findOne(_ collection: String, _ query: [String : Any], options: FindOptions) -> HivePromise<[String : Any]> {
        return authHelper.checkValid().then { _ -> HivePromise<[String: Any]> in
            return self.findOneImp(collection, query, options, tryAgain: 0)
        }
    }

    private func findOneImp(_ collection: String, _ query: [String: Any], _ options: FindOptions, tryAgain: Int) -> HivePromise<[String: Any]> {
        return HivePromise<[String: Any]> { resolver in
            var param = ["collection": collection, "filter": query] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = VaultURL.sharedInstance.findOne()

            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<[String: Any]> in
                            return self.findOneImp(collection, query, options, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(DatabaseClient.TAG, "findOne ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    resolver.fulfill(json.dictionaryObject!)
                }
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    public func findMany(_ collection: String, _ query: [String : Any], options: FindOptions) -> HivePromise<Array<[String : Any]>> {
        return authHelper.checkValid().then { _ -> HivePromise<Array<[String : Any]>> in
            return self.findManyImp(collection, query, options, tryAgain: 0)
        }
    }

    private func findManyImp(_ collection: String, _ query: [String: Any], _ options: FindOptions, tryAgain: Int) -> HivePromise<Array<[String: Any]>> {
        return HivePromise<Array<[String: Any]>> { resolver in
            var param = ["collection": collection, "filter": query] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = VaultURL.sharedInstance.findMany()

            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<Array<[String: Any]>> in
                            return self.findManyImp(collection, query, options, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(DatabaseClient.TAG, "findMany ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    var items: [Dictionary<String, Any>] = []
                    json["items"].arrayValue.forEach { json in
                        items.append(json.dictionaryObject!)
                    }
                    resolver.fulfill(items)
                }
            }.catch { error in
                Log.e(DatabaseClient.TAG, "findMany ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions) -> HivePromise<UpdateResult> {
        return authHelper.checkValid().then { _ -> HivePromise<UpdateResult> in
            return self.updateOneImp(collection, filter, update, options, tryAgain: 0)
        }
    }

    private func updateOneImp(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions, tryAgain: Int) -> HivePromise<UpdateResult> {
        return HivePromise<UpdateResult> { resolver in
            var param = ["collection": collection, "filter": filter, "update": update] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = VaultURL.sharedInstance.updateOne()

            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<UpdateResult> in
                            return self.updateOneImp(collection, filter, update, options, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(DatabaseClient.TAG, "updateOne error: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    let updateRe = UpdateResult(json)
                    resolver.fulfill(updateRe)
                }
            }.catch { error in
                Log.e(DatabaseClient.TAG, "updateOne error: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func updateMany(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions) -> HivePromise<UpdateResult> {
        return authHelper.checkValid().then { _ -> HivePromise<UpdateResult> in
            return self.updateManyImp(collection, filter, update, options, tryAgain: 0)
        }
    }

    private func updateManyImp(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions, tryAgain: Int) -> HivePromise<UpdateResult>{
        return HivePromise<UpdateResult> { resolver in
            var param = ["collection": collection, "filter": filter, "update": update] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = VaultURL.sharedInstance.updateMany()

            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<UpdateResult> in
                            return self.updateManyImp(collection, filter, update, options, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(DatabaseClient.TAG, "updateMany ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    let updateRe = UpdateResult(json)
                    resolver.fulfill(updateRe)
                }
            }.catch { error in
                Log.e(DatabaseClient.TAG, "updateMany ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func deleteOne(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> HivePromise<DeleteResult> {
        return authHelper.checkValid().then { _ -> HivePromise<DeleteResult> in
            return self.deleteOneImp(collection, filter, options, tryAgain: 0)
        }
    }

    private func deleteOneImp(_ collection: String, _ filter: [String: Any], _ options: DeleteOptions, tryAgain: Int) -> HivePromise<DeleteResult>{
        return HivePromise<DeleteResult> { resolver in
            var param = ["collection": collection, "filter": filter] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = VaultURL.sharedInstance.deleteOne()

            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<DeleteResult> in
                            return self.deleteOneImp(collection, filter, options, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(DatabaseClient.TAG, "deleteOne ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    let deleteRe = DeleteResult(json)
                    resolver.fulfill(deleteRe)
                }
            }.catch { error in
                Log.e(DatabaseClient.TAG, "deleteOne ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func deleteMany(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> HivePromise<DeleteResult> {
        return authHelper.checkValid().then { _ -> HivePromise<DeleteResult> in
            return self.deleteManyImp(collection, filter, options, tryAgain: 0)
        }
    }

    private func deleteManyImp(_ collection: String, _ filter: [String: Any], _ options: DeleteOptions, tryAgain: Int) -> HivePromise<DeleteResult>{
        return HivePromise<DeleteResult> { resolver in
            var param = ["collection": collection, "filter": filter] as [String : Any]
            if try options.jsonSerialize().count != 0 {
                param["options"] = try options.jsonSerialize()
            }
            let url = VaultURL.sharedInstance.deleteMany()

            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<DeleteResult> in
                            return self.deleteManyImp(collection, filter, options, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(DatabaseClient.TAG, "deleteMany ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    let deleteRe = DeleteResult(json)
                    resolver.fulfill(deleteRe)
                }
            }.catch { error in
                Log.e(DatabaseClient.TAG, "deleteMany ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }
}