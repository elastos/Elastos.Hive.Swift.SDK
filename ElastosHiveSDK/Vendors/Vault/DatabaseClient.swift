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
            return self.createColImp(name, nil, HiveCallback())
        }
    }

    public func createCollection(_ name: String, options: CreateCollectionOptions) -> HivePromise<Bool> {
        return createCollection(name, options: options, handler: HiveCallback())
    }

    public func createCollection(_ name: String, options: CreateCollectionOptions, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.createColImp(name, options, handler)
        }
    }

    private func createColImp(_ collection: String, _ options: CreateCollectionOptions?, _ handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let param = ["collection": collection]
        let header = Header(authHelper)
        let url = VaultURL.sharedInstance.mongoDBSetup()

        return VaultApi.requestWithBool(url: url, parameters: param, headers: header.headers(), handler: handleBy)
    }

    public func deleteCollection(_ name: String) -> HivePromise<Bool> {
        return self.deleteCollection(name, handler: HiveCallback())
    }

    public func deleteCollection(_ name: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.deleteColImp(name, handler)
        }
    }

    private func deleteColImp(_ collection: String, _ handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let param = ["collection": collection]
        let header = Header(authHelper)
        let url = VaultURL.sharedInstance.deleteMongoDBCollection()

        return VaultApi.requestWithBool(url: url, parameters: param, headers: header.headers(), handler: handleBy)
    }

    public func insertOne(_ collection: String, _ doc: [String : Any], options: InsertOptions?) -> HivePromise<InsertResult> {
        return self.insertOne(collection, doc, options: options, handler: HiveCallback())
    }

    public func insertOne(_ collection: String, _ doc: [String : Any], options: InsertOptions?, handler: HiveCallback<InsertResult>) -> HivePromise<InsertResult> {
        return authHelper.checkValid().then { _ -> HivePromise<InsertResult> in
            return self.insertOneImp(collection, doc, options, handler)
        }
    }

    private func insertOneImp(_ collection: String, _ doc: [String: Any], _ options: InsertOptions?, _ handleBy: HiveCallback<InsertResult>) -> HivePromise<InsertResult> {
        let param = ["collection": collection, "document": doc] as [String : Any]
        let url = VaultURL.sharedInstance.insertOne()

        return VaultApi.requestWithInsert(url: url, parameters: param, headers: Header(authHelper).headers(), handler: handleBy)
    }

    public func insertMany(_ collection: String, _ docs: Array<[String : Any]>, options: InsertOptions) -> HivePromise<InsertResult> {
        return insertMany(collection, docs, options: options, handler: HiveCallback())
    }

    public func insertMany(_ collection: String, _ docs: Array<[String : Any]>, options: InsertOptions, handler: HiveCallback<InsertResult>) -> HivePromise<InsertResult> {
        return authHelper.checkValid().then { _ -> HivePromise<InsertResult> in
            return self.insertManyImp(collection, docs, options, handler)
        }
    }

    private func insertManyImp(_ collection: String, _ doc: Array<[String: Any]>, _ options: InsertOptions, _ handleBy: HiveCallback<InsertResult>) -> HivePromise<InsertResult> {
        let param = ["collection": collection, "document": doc] as [String : Any]
        let url = VaultURL.sharedInstance.insertMany()

        return VaultApi.requestWithInsert(url: url, parameters: param, headers: Header(authHelper).headers(), handler: handleBy)
    }

    public func countDocuments(_ collection: String, _ query: [String : Any], options: CountOptions) -> HivePromise<Int> {
        return countDocuments(collection, query, options: options, handler: HiveCallback())
    }

    public func countDocuments(_ collection: String, _ query: [String : Any], options: CountOptions, handler: HiveCallback<Int>) -> HivePromise<Int> {
        return authHelper.checkValid().then { _ -> HivePromise<Int> in
            return self.countDocumentsImp(collection, query, options, handler)
        }
    }

    private func countDocumentsImp(_ collection: String, _ query: [String: Any], _ options: CountOptions, _ handleBy: HiveCallback<Int>) -> HivePromise<Int> {
        let param = ["collection": collection, "filter": query] as [String : Any]
        let url = VaultURL.sharedInstance.countDocuments()

        return HivePromise<Int> { resolver in
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { json in
                handleBy.didSucceed(json["count"].intValue)
                resolver.fulfill(json["count"].intValue)
            }.catch { error in
                handleBy.runError(HiveError.netWork(des: error))
                resolver.reject(error)
            }
        }
    }

    public func findOne(_ collection: String, _ query: [String : Any], options: FindOptions) -> HivePromise<[String : Any]> {
        return self.findOne(collection, query, options: options, handler: HiveCallback())
    }

    public func findOne(_ collection: String, _ query: [String : Any], options: FindOptions, handler: HiveCallback<[String : Any]>) -> HivePromise<[String : Any]> {
        return authHelper.checkValid().then { _ -> HivePromise<[String: Any]> in
            return self.findOneImp(collection, query, options, handler)
        }
    }

    private func findOneImp(_ collection: String, _ query: [String: Any], _ options: FindOptions, _ handleBy: HiveCallback<[String: Any]>) -> HivePromise<[String: Any]> {
        let param = ["collection": collection, "filter": query] as [String : Any]
        let url = VaultURL.sharedInstance.findOne()

        return HivePromise<[String: Any]> { resolver in
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                handleBy.didSucceed(json.dictionaryObject!)
                resolver.fulfill(json.dictionaryObject!)
            }.catch { error in
                handleBy.runError(HiveError.netWork(des: error))
                resolver.reject(error)
            }
        }
    }

    public func findMany(_ collection: String, _ query: [String : Any], options: FindOptions) -> HivePromise<Array<[String : Any]>> {
        return self.findMany(collection, query, options: options, handler: HiveCallback())
    }

    public func findMany(_ collection: String, _ query: [String : Any], options: FindOptions, handler: HiveCallback<Array<[String : Any]>>) -> HivePromise<Array<[String : Any]>> {
        return authHelper.checkValid().then { _ -> HivePromise<Array<[String : Any]>> in
            return self.findManyImp(collection, query, options, HiveCallback())
        }
    }

    private func findManyImp(_ collection: String, _ query: [String: Any], _ options: FindOptions, _ handleBy: HiveCallback<Array<[String: Any]>>) -> HivePromise<Array<[String: Any]>> {
        let param = ["collection": collection, "filter": query] as [String : Any]
        let url = VaultURL.sharedInstance.findMany()

        return HivePromise<Array<[String: Any]>> { resolver in
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                var items: [Dictionary<String, Any>] = []
                json["items"].arrayValue.forEach { json in
                    items.append(json.dictionaryObject!)
                }
                handleBy.didSucceed(items)
                resolver.fulfill(items)
            }.catch { error in
                handleBy.runError(HiveError.netWork(des: error))
                resolver.reject(error)
            }
        }
    }

    public func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions) -> HivePromise<UpdateResult> {
        return self.updateOne(collection, filter, update, options: options, handler: HiveCallback())
    }

    public func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions, handler: HiveCallback<UpdateResult>) -> HivePromise<UpdateResult> {
        return authHelper.checkValid().then { _ -> HivePromise<UpdateResult> in
            return self.updateOneImp(collection, filter, update, options, handler)
        }
    }

    private func updateOneImp(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions, _ handleBy: HiveCallback<UpdateResult>) -> HivePromise<UpdateResult> {
        let param = ["collection": collection, "filter": filter, "update": ["$set": update]] as [String : Any]
        let url = VaultURL.sharedInstance.updateOne()

        return HivePromise<UpdateResult> { resolver in
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                let updateRe = UpdateResult(json)
                handleBy.didSucceed(updateRe)
                resolver.fulfill(updateRe)
            }.catch { error in
                handleBy.runError(HiveError.netWork(des: error))
                resolver.reject(error)
            }
        }
    }

    public func updateMany(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions) -> HivePromise<UpdateResult> {
        return self.updateMany(collection, filter, update, options: options, handler: HiveCallback())
    }

    public func updateMany(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions, handler: HiveCallback<UpdateResult>) -> HivePromise<UpdateResult> {
        return authHelper.checkValid().then { _ -> HivePromise<UpdateResult> in
            return self.updateManyImp(collection, filter, update, options, handler)
        }
    }

    private func updateManyImp(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions, _ handleBy: HiveCallback<UpdateResult>) -> HivePromise<UpdateResult>{
        let param = ["collection": collection, "filter": filter, "update": ["$set": update]] as [String : Any]
        let url = VaultURL.sharedInstance.updateMany()

        return HivePromise<UpdateResult> { resolver in
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                let updateRe = UpdateResult(json)
                handleBy.didSucceed(updateRe)
                resolver.fulfill(updateRe)
            }.catch { error in
                handleBy.runError(HiveError.netWork(des: error))
                resolver.reject(error)
            }
        }
    }

    public func deleteOne(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> HivePromise<DeleteResult> {
        return self.deleteOne(collection, filter, options: options, handler: HiveCallback())
    }

    public func deleteOne(_ collection: String, _ filter: [String : Any], options: DeleteOptions, handler: HiveCallback<DeleteResult>) -> HivePromise<DeleteResult> {
        return authHelper.checkValid().then { _ -> HivePromise<DeleteResult> in
            return self.deleteOneImp(collection, filter, options, handler)
        }
    }

    private func deleteOneImp(_ collection: String, _ filter: [String: Any], _ options: DeleteOptions, _ handleBy: HiveCallback<DeleteResult>) -> HivePromise<DeleteResult>{
        let param = ["collection": collection, "filter": filter] as [String : Any]
        let url = VaultURL.sharedInstance.deleteOne()

        return HivePromise<DeleteResult> { resolver in
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                let deleteRe = DeleteResult(json)
                handleBy.didSucceed(deleteRe)
                resolver.fulfill(deleteRe)
            }.catch { error in
                handleBy.runError(HiveError.netWork(des: error))
                resolver.reject(error)
            }
        }
    }

    public func deleteMany(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> HivePromise<DeleteResult> {
        return self.deleteMany(collection, filter, options: options, handler: HiveCallback())
    }

    public func deleteMany(_ collection: String, _ filter: [String : Any], options: DeleteOptions, handler: HiveCallback<DeleteResult>) -> HivePromise<DeleteResult> {
        return authHelper.checkValid().then { _ -> HivePromise<DeleteResult> in
            return self.deleteManyImp(collection, filter, options, handler)
        }
    }

    private func deleteManyImp(_ collection: String, _ filter: [String: Any], _ options: DeleteOptions, _ handleBy: HiveCallback<DeleteResult>) -> HivePromise<DeleteResult>{
        let param = ["collection": collection, "filter": filter] as [String : Any]
        let url = VaultURL.sharedInstance.deleteMany()

        return HivePromise<DeleteResult> { resolver in
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).get { json in
                let deleteRe = DeleteResult(json)
                handleBy.didSucceed(deleteRe)
                resolver.fulfill(deleteRe)
            }.catch { error in
                handleBy.runError(HiveError.netWork(des: error))
                resolver.reject(error)
            }
        }
    }
}
