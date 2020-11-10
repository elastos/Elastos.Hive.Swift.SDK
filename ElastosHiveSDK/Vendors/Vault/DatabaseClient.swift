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
    private var authHelper: VaultAuthHelper

    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }
    
    public func createCollection(_ name: String) -> HivePromise<Bool> {
        return self.createCollection(name, handler: HiveCallback())
    }

    public func createCollection(_ name: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.createColImp(name, nil, HiveCallback(), tryAgain: 0)
        }
    }

    public func createCollection(_ name: String, options: CreateCollectionOptions) -> HivePromise<Bool> {
        return createCollection(name, options: options, handler: HiveCallback())
    }

    public func createCollection(_ name: String, options: CreateCollectionOptions, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.createColImp(name, options, handler, tryAgain: 0)
        }
    }
    
    private func createColImp(_ collection: String, _ options: CreateCollectionOptions?, _ handleBy: HiveCallback<Bool>, tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            let param = ["collection": collection]
            let header = Header(authHelper)
            let url = VaultURL.sharedInstance.mongoDBSetup()
            
            VaultApi.request(url: url, parameters: param, headers: header.headers()).done { json in
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<Bool> in
                            return self.createColImp(collection, options, handleBy, tryAgain: 1)
                        }.done { success in
                            resolver.fulfill(true)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        var dic: [String: Any] = [: ]
                        json.forEach { key, value in
                            dic[key] = value
                        }
                        resolver.reject(HiveError.failureWithDic(des: dic))
                    }
                }
                resolver.fulfill(true)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    public func deleteCollection(_ name: String) -> HivePromise<Bool> {
        return self.deleteCollection(name, handler: HiveCallback())
    }

    public func deleteCollection(_ name: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.deleteColImp(name, handler, tryAgain: 0)
        }
    }
    
    private func deleteColImp(_ collection: String, _ handleBy: HiveCallback<Bool>, tryAgain: Int) -> HivePromise<Bool> {
        return HivePromise<Bool> { resolver in
            let param = ["collection": collection]
            let header = Header(authHelper)
            let url = VaultURL.sharedInstance.deleteMongoDBCollection()
            
            VaultApi.request(url: url, parameters: param, headers: header.headers()).done { json in
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<Bool> in
                            return self.deleteColImp(collection, handleBy, tryAgain: 1)
                        }.done { success in
                            resolver.fulfill(true)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        var dic: [String: Any] = [: ]
                        json.forEach { key, value in
                            dic[key] = value
                        }
                        resolver.reject(HiveError.failureWithDic(des: dic))
                    }
                }
                resolver.fulfill(true)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    public func insertOne(_ collection: String, _ doc: [String : Any], options: InsertOptions?) -> HivePromise<InsertOneResult> {
        return self.insertOne(collection, doc, options: options, handler: HiveCallback())
    }

    public func insertOne(_ collection: String, _ doc: [String : Any], options: InsertOptions?, handler: HiveCallback<InsertOneResult>) -> HivePromise<InsertOneResult> {
        return authHelper.checkValid().then { _ -> HivePromise<InsertOneResult> in
            return self.insertOneImp(collection, doc, options, handler, tryAgain: 0)
        }
    }
    
    private func insertOneImp(_ collection: String, _ doc: [String: Any], _ options: InsertOptions?, _ handleBy: HiveCallback<InsertOneResult>, tryAgain: Int) -> HivePromise<InsertOneResult> {
        HivePromise<InsertOneResult> { resolver in
            let param = ["collection": collection, "document": doc] as [String : Any]
            let url = VaultURL.sharedInstance.insertOne()
            
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { json in
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<InsertOneResult> in
                            return self.insertOneImp(collection, doc, options, handleBy, tryAgain: 1)
                        }.done { insertResult in
                            resolver.fulfill(insertResult)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        var dic: [String: Any] = [: ]
                        json.forEach { key, value in
                            dic[key] = value
                        }
                        resolver.reject(HiveError.failureWithDic(des: dic))
                    }
                }
                let insertOneResult = InsertOneResult(json)
                resolver.fulfill(insertOneResult)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    public func insertMany(_ collection: String, _ docs: Array<[String : Any]>, options: InsertOptions) -> HivePromise<InsertManyResult> {
        return insertMany(collection, docs, options: options, handler: HiveCallback())
    }

    public func insertMany(_ collection: String, _ docs: Array<[String : Any]>, options: InsertOptions, handler: HiveCallback<InsertManyResult>) -> HivePromise<InsertManyResult> {
        return authHelper.checkValid().then { _ -> HivePromise<InsertManyResult> in
            return self.insertManyImp(collection, docs, options, handler, tryAgain: 0)
        }
    }
    
    private func insertManyImp(_ collection: String, _ doc: Array<[String: Any]>, _ options: InsertOptions, _ handleBy: HiveCallback<InsertManyResult>, tryAgain: Int) -> HivePromise<InsertManyResult> {
        HivePromise<InsertManyResult> { resolver in
            let param = ["collection": collection, "document": doc] as [String : Any]
            let url = VaultURL.sharedInstance.insertMany()
            
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { json in
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<InsertManyResult> in
                            return self.insertManyImp(collection, doc, options, handleBy, tryAgain: 1)
                        }.done { insertResult in
                            resolver.fulfill(insertResult)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        var dic: [String: Any] = [: ]
                        json.forEach { key, value in
                            dic[key] = value
                        }
                        resolver.reject(HiveError.failureWithDic(des: dic))
                    }
                }
                let insertManyResult = InsertManyResult(json)
                resolver.fulfill(insertManyResult)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    public func countDocuments(_ collection: String, _ query: [String : Any], options: CountOptions) -> HivePromise<Int> {
        return countDocuments(collection, query, options: options, handler: HiveCallback())
    }

    public func countDocuments(_ collection: String, _ query: [String : Any], options: CountOptions, handler: HiveCallback<Int>) -> HivePromise<Int> {
        return authHelper.checkValid().then { _ -> HivePromise<Int> in
            return self.countDocumentsImp(collection, query, options, handler, tryAgain: 0)
        }
    }

    private func countDocumentsImp(_ collection: String, _ query: [String: Any], _ options: CountOptions, _ handleBy: HiveCallback<Int>, tryAgain: Int) -> HivePromise<Int> {
        let param = ["collection": collection, "filter": query] as [String : Any]
        let url = VaultURL.sharedInstance.countDocuments()

        return HivePromise<Int> { resolver in
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { json in
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<Int> in
                            return self.countDocumentsImp(collection, query, options, handleBy, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        var dic: [String: Any] = [: ]
                        json.forEach { key, value in
                            dic[key] = value
                        }
                        resolver.reject(HiveError.failureWithDic(des: dic))
                    }
                }
                handleBy.didSucceed(json["count"].intValue)
                resolver.fulfill(json["count"].intValue)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    public func findOne(_ collection: String, _ query: [String : Any], options: FindOptions) -> HivePromise<[String : Any]> {
        return self.findOne(collection, query, options: options, handler: HiveCallback())
    }

    public func findOne(_ collection: String, _ query: [String : Any], options: FindOptions, handler: HiveCallback<[String : Any]>) -> HivePromise<[String : Any]> {
        return authHelper.checkValid().then { _ -> HivePromise<[String: Any]> in
            return self.findOneImp(collection, query, options, handler, tryAgain: 1)
        }
    }

    private func findOneImp(_ collection: String, _ query: [String: Any], _ options: FindOptions, _ handleBy: HiveCallback<[String: Any]>, tryAgain: Int) -> HivePromise<[String: Any]> {
        let param = ["collection": collection, "filter": query] as [String : Any]
        let url = VaultURL.sharedInstance.findOne()

        return HivePromise<[String: Any]> { resolver in
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<[String: Any]> in
                            return self.findOneImp(collection, query, options, handleBy, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        var dic: [String: Any] = [: ]
                        json.forEach { key, value in
                            dic[key] = value
                        }
                        resolver.reject(HiveError.failureWithDic(des: dic))
                    }
                }
                handleBy.didSucceed(json.dictionaryObject!)
                resolver.fulfill(json.dictionaryObject!)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    public func findMany(_ collection: String, _ query: [String : Any], options: FindOptions) -> HivePromise<Array<[String : Any]>> {
        return self.findMany(collection, query, options: options, handler: HiveCallback())
    }

    public func findMany(_ collection: String, _ query: [String : Any], options: FindOptions, handler: HiveCallback<Array<[String : Any]>>) -> HivePromise<Array<[String : Any]>> {
        return authHelper.checkValid().then { _ -> HivePromise<Array<[String : Any]>> in
            return self.findManyImp(collection, query, options, HiveCallback(), tryAgain: 0)
        }
    }

    private func findManyImp(_ collection: String, _ query: [String: Any], _ options: FindOptions, _ handleBy: HiveCallback<Array<[String: Any]>>, tryAgain: Int) -> HivePromise<Array<[String: Any]>> {
        let param = ["collection": collection, "filter": query] as [String : Any]
        let url = VaultURL.sharedInstance.findMany()

        return HivePromise<Array<[String: Any]>> { resolver in
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<Array<[String: Any]>> in
                            return self.findManyImp(collection, query, options, handleBy, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        var dic: [String: Any] = [: ]
                        json.forEach { key, value in
                            dic[key] = value
                        }
                        resolver.reject(HiveError.failureWithDic(des: dic))
                    }
                }
                var items: [Dictionary<String, Any>] = []
                json["items"].arrayValue.forEach { json in
                    items.append(json.dictionaryObject!)
                }
                handleBy.didSucceed(items)
                resolver.fulfill(items)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    public func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions) -> HivePromise<UpdateResult> {
        return self.updateOne(collection, filter, update, options: options, handler: HiveCallback())
    }

    public func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions, handler: HiveCallback<UpdateResult>) -> HivePromise<UpdateResult> {
        return authHelper.checkValid().then { _ -> HivePromise<UpdateResult> in
            return self.updateOneImp(collection, filter, update, options, handler, tryAgain: 0)
        }
    }

    private func updateOneImp(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions, _ handleBy: HiveCallback<UpdateResult>, tryAgain: Int) -> HivePromise<UpdateResult> {
        let param = ["collection": collection, "filter": filter, "update": ["$set": update]] as [String : Any]
        let url = VaultURL.sharedInstance.updateOne()

        return HivePromise<UpdateResult> { resolver in
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<UpdateResult> in
                            return self.updateOneImp(collection, filter, update, options, handleBy, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        var dic: [String: Any] = [: ]
                        json.forEach { key, value in
                            dic[key] = value
                        }
                        resolver.reject(HiveError.failureWithDic(des: dic))
                    }
                }
                let updateRe = UpdateResult(json)
                handleBy.didSucceed(updateRe)
                resolver.fulfill(updateRe)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    public func updateMany(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions) -> HivePromise<UpdateResult> {
        return self.updateMany(collection, filter, update, options: options, handler: HiveCallback())
    }

    public func updateMany(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions, handler: HiveCallback<UpdateResult>) -> HivePromise<UpdateResult> {
        return authHelper.checkValid().then { _ -> HivePromise<UpdateResult> in
            return self.updateManyImp(collection, filter, update, options, handler, tryAgain: 0)
        }
    }

    private func updateManyImp(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions, _ handleBy: HiveCallback<UpdateResult>, tryAgain: Int) -> HivePromise<UpdateResult>{
        let param = ["collection": collection, "filter": filter, "update": ["$set": update]] as [String : Any]
        let url = VaultURL.sharedInstance.updateMany()

        return HivePromise<UpdateResult> { resolver in
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<UpdateResult> in
                            return self.updateManyImp(collection, filter, update, options, handleBy, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        var dic: [String: Any] = [: ]
                        json.forEach { key, value in
                            dic[key] = value
                        }
                        resolver.reject(HiveError.failureWithDic(des: dic))
                    }
                }
                let updateRe = UpdateResult(json)
                handleBy.didSucceed(updateRe)
                resolver.fulfill(updateRe)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    public func deleteOne(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> HivePromise<DeleteResult> {
        return self.deleteOne(collection, filter, options: options, handler: HiveCallback())
    }

    public func deleteOne(_ collection: String, _ filter: [String : Any], options: DeleteOptions, handler: HiveCallback<DeleteResult>) -> HivePromise<DeleteResult> {
        return authHelper.checkValid().then { _ -> HivePromise<DeleteResult> in
            return self.deleteOneImp(collection, filter, options, handler, tryAgain: 0)
        }
    }
    
    private func deleteOneImp(_ collection: String, _ filter: [String: Any], _ options: DeleteOptions, _ handleBy: HiveCallback<DeleteResult>, tryAgain: Int) -> HivePromise<DeleteResult>{
        let param = ["collection": collection, "filter": filter] as [String : Any]
        let url = VaultURL.sharedInstance.deleteOne()
        
        return HivePromise<DeleteResult> { resolver in
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { json in
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<DeleteResult> in
                            return self.deleteOneImp(collection, filter, options, handleBy, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        var dic: [String: Any] = [: ]
                        json.forEach { key, value in
                            dic[key] = value
                        }
                        resolver.reject(HiveError.failureWithDic(des: dic))
                    }
                }
                let deleteRe = DeleteResult(json)
                handleBy.didSucceed(deleteRe)
                resolver.fulfill(deleteRe)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    public func deleteMany(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> HivePromise<DeleteResult> {
        return self.deleteMany(collection, filter, options: options, handler: HiveCallback())
    }

    public func deleteMany(_ collection: String, _ filter: [String : Any], options: DeleteOptions, handler: HiveCallback<DeleteResult>) -> HivePromise<DeleteResult> {
        return authHelper.checkValid().then { _ -> HivePromise<DeleteResult> in
            return self.deleteManyImp(collection, filter, options, handler, tryAgain: 0)
        }
    }
    
    private func deleteManyImp(_ collection: String, _ filter: [String: Any], _ options: DeleteOptions, _ handleBy: HiveCallback<DeleteResult>, tryAgain: Int) -> HivePromise<DeleteResult>{
        let param = ["collection": collection, "filter": filter] as [String : Any]
        let url = VaultURL.sharedInstance.deleteMany()
        
        return HivePromise<DeleteResult> { resolver in
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                let status = json["_status"].stringValue
                if status == "ERR" {
                    let errorCode = json["_error"]["code"].intValue
                    let errorMessage = json["_error"]["message"].stringValue
                    if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                        self.authHelper.retryLogin().then { success -> HivePromise<DeleteResult> in
                            return self.deleteManyImp(collection, filter, options, handleBy, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        var dic: [String: Any] = [: ]
                        json.forEach { key, value in
                            dic[key] = value
                        }
                        resolver.reject(HiveError.failureWithDic(des: dic))
                    }
                }
                let deleteRe = DeleteResult(json)
                handleBy.didSucceed(deleteRe)
                resolver.fulfill(deleteRe)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
}
