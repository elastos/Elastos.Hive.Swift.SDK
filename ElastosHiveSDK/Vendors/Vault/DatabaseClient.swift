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

class DatabaseClient: DatabaseProtocol {
    private var authHelper: VaultAuthHelper

    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }

    func createCollection(_ name: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.createCollection(name, handler: HiveCallback())
        }
    }

    func createCollection(_ name: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return createColImp(name, nil, HiveCallback())
    }

    func createCollection(_ name: String, options: CreateCollectionOptions) -> HivePromise<Bool> {
        return createColImp(name, options, HiveCallback())
    }

    func createCollection(_ name: String, options: CreateCollectionOptions, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return createColImp(name, options, handler)
    }

    private func createColImp(_ collection: String, _ options: CreateCollectionOptions?, _ handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let param = ["collection": collection]
        let header = Header(authHelper)
        let url = VaultURL.sharedInstance.mongoDBSetup()

        return VaultApi.requestWithBool(url: url, parameters: param, headers: header.headers())
    }

    func deleteCollection(_ name: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.deleteColImp(name, HiveCallback())
        }
    }

    func deleteCollection(_ name: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return deleteColImp(name, handler)
    }

    private func deleteColImp(_ collection: String, _ handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let param = ["collection": collection]
        let header = Header(authHelper)
        let url = VaultURL.sharedInstance.deleteMongoDBCollection()

        return VaultApi.requestWithBool(url: url, parameters: param, headers: header.headers())
    }

    func insertOne(_ collection: String, _ doc: [String : Any], options: InsertOptions?) -> HivePromise<InsertResult> {
        return authHelper.checkValid().then { _ -> HivePromise<InsertResult> in
            return self.insertOne(collection, doc, options: options, handler: HiveCallback())
        }
    }

    func insertOne(_ collection: String, _ doc: [String : Any], options: InsertOptions?, handler: HiveCallback<InsertResult>) -> HivePromise<InsertResult> {
        return insertOneImp(collection, doc, options, handler)
    }

    private func insertOneImp(_ collection: String, _ doc: [String: Any], _ options: InsertOptions?, _ handleBy: HiveCallback<InsertResult>) -> HivePromise<InsertResult> {
        let param = ["collection": collection, "document": doc] as [String : Any]
        let url = VaultURL.sharedInstance.insertOne()

        return VaultApi.requestWithInsert(url: url, parameters: param, headers: Header(authHelper).headers())
    }

    func insertMany(_ collection: String, _ docs: Array<[String : Any]>, options: InsertOptions) -> HivePromise<InsertResult> {
        return insertMany(collection, docs, options: options, handler: HiveCallback())
    }

    func insertMany(_ collection: String, _ docs: Array<[String : Any]>, options: InsertOptions, handler: HiveCallback<InsertResult>) -> HivePromise<InsertResult> {
        return insertManyImp(collection, docs, options, handler)
    }

    private func insertManyImp(_ collection: String, _ doc: Array<[String: Any]>, _ options: InsertOptions, _ handleBy: HiveCallback<InsertResult>) -> HivePromise<InsertResult> {
        let param = ["collection": collection]
        let url = VaultURL.sharedInstance.insertMany()

        return VaultApi.requestWithInsert(url: url, parameters: param)
    }

    func countDocuments(_ collection: String, _ query: [String : Any], options: CountOptions) -> HivePromise<Int> {
        return countDocuments(collection, query, options: options, handler: HiveCallback())
    }

    func countDocuments(_ collection: String, _ query: [String : Any], options: CountOptions, handler: HiveCallback<Int>) -> HivePromise<Int> {
        return countDocumentsImp(collection, query, options, handler)
    }

    private func countDocumentsImp(_ collection: String, _ query: [String: Any], _ options: CountOptions, _ handleBy: HiveCallback<Int>) -> HivePromise<Int> {
        let param = ["collection": collection]
        let url = VaultURL.sharedInstance.countDocuments()

        return HivePromise<Int> { resolver in
            VaultApi.request(url: url, parameters: param).get { json in
                resolver.fulfill(0)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    func findOne(_ collection: String, _ query: [String : Any], options: FindOptions) -> HivePromise<[String : Any]> {
        return findOne(collection, query, options: options, handler: HiveCallback())
    }

    func findOne(_ collection: String, _ query: [String : Any], options: FindOptions, handler: HiveCallback<[String : Any]>) -> HivePromise<[String : Any]> {
        return findOneImp(collection, query, options, handler)
    }

    private func findOneImp(_ collection: String, _ query: [String: Any], _ options: FindOptions, _ handleBy: HiveCallback<[String: Any]>) -> HivePromise<[String: Any]> {
        let param = ["collection": collection]
        let url = VaultURL.sharedInstance.findOne()

        return HivePromise<[String: Any]> { resolver in
            VaultApi.request(url: url, parameters: param).get { json in
                resolver.fulfill(["TODO": "TODO"])
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    func findMany(_ collection: String, _ query: [String : Any], options: FindOptions) -> HivePromise<Array<[String : Any]>> {
        return findMany(collection, query, options: options, handler: HiveCallback())
    }

    func findMany(_ collection: String, _ query: [String : Any], options: FindOptions, handler: HiveCallback<Array<[String : Any]>>) -> HivePromise<Array<[String : Any]>> {
        return findManyImp(collection, query, options, HiveCallback())
    }

    private func findManyImp(_ collection: String, _ query: [String: Any], _ options: FindOptions, _ handleBy: HiveCallback<Array<[String: Any]>>) -> HivePromise<Array<[String: Any]>> {
        let param = ["collection": collection]
        let url = VaultURL.sharedInstance.findMany()

        return HivePromise<Array<[String: Any]>> { resolver in
            VaultApi.request(url: url, parameters: param).get { json in
                resolver.fulfill([["TODO": "TODO"]])
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions) -> HivePromise<UpdateResult> {
        return updateOne(collection, filter, update, options: options, handler: HiveCallback())
    }

    func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions, handler: HiveCallback<UpdateResult>) -> HivePromise<UpdateResult> {
        return updateOneImp(collection, filter, update, options, handler)
    }

    private func updateOneImp(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions, _ handleBy: HiveCallback<UpdateResult>) -> HivePromise<UpdateResult> {
        let param = ["collection": collection]
        let url = VaultURL.sharedInstance.updateOne()

        return HivePromise<UpdateResult> { resolver in
            VaultApi.request(url: url, parameters: param).get { json in
                resolver.fulfill(UpdateResult())
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    func updateMany(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions) -> HivePromise<UpdateResult> {
        return updateMany(collection, filter, update, options: options, handler: HiveCallback())
    }

    func updateMany(_ collection: String, _ filter: [String : Any], _ update: [String : Any], options: UpdateOptions, handler: HiveCallback<UpdateResult>) -> HivePromise<UpdateResult> {
        return updateManyImp(collection, filter, update, options, handler)
    }

    private func updateManyImp(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions, _ handleBy: HiveCallback<UpdateResult>) -> HivePromise<UpdateResult>{
        let param = ["collection": collection]
        let url = VaultURL.sharedInstance.updateMany()

        return HivePromise<UpdateResult> { resolver in
            VaultApi.request(url: url, parameters: param).get { json in
                resolver.fulfill(UpdateResult())
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    func deleteOne(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> HivePromise<DeleteResult> {
        return deleteOne(collection, filter, options: options, handler: HiveCallback())
    }

    func deleteOne(_ collection: String, _ filter: [String : Any], options: DeleteOptions, handler: HiveCallback<DeleteResult>) -> HivePromise<DeleteResult> {
        return deleteOneImp(collection, filter, options, handler)
    }

    private func deleteOneImp(_ collection: String, _ filter: [String: Any], _ options: DeleteOptions, _ handleBy: HiveCallback<DeleteResult>) -> HivePromise<DeleteResult>{
        let param = ["collection": collection]
        let url = VaultURL.sharedInstance.deleteOne()

        return HivePromise<DeleteResult> { resolver in
            VaultApi.request(url: url, parameters: param).get { json in
                resolver.fulfill(DeleteResult())
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    func deleteMany(_ collection: String, _ filter: [String : Any], options: DeleteOptions) -> HivePromise<DeleteResult> {
        return deleteMany(collection, filter, options: options, handler: HiveCallback())
    }

    func deleteMany(_ collection: String, _ filter: [String : Any], options: DeleteOptions, handler: HiveCallback<DeleteResult>) -> HivePromise<DeleteResult> {
        return deleteManyImp(collection, filter, options, handler)
    }

    private func deleteManyImp(_ collection: String, _ filter: [String: Any], _ options: DeleteOptions, _ handleBy: HiveCallback<DeleteResult>) -> HivePromise<DeleteResult>{
        let param = ["collection": collection]
        let url = VaultURL.sharedInstance.deleteMany()

        return HivePromise<DeleteResult> { resolver in
            VaultApi.request(url: url, parameters: param).get { json in
                resolver.fulfill(DeleteResult())
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

}
