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

public class EncryptionDatabaseRender: DatabaseServiceRender {

    public let _databaseEncrypt: DatabaseEncryption
    
    public init(_ serviceEndpoint: ServiceEndpoint, _ cipher: DIDCipher, _ nonce: [UInt8]) {
        self._databaseEncrypt = DatabaseEncryption(cipher, nonce)
        super.init(serviceEndpoint)
    }
    
    public override func createCollection(_ name: String) -> Promise<Void> {
        super.createCollectionInternal(name, isEncrypt: true)
    }
    
    public override func deleteCollection(_ name: String) -> Promise<Void> {
        return super.deleteCollection(name)
    }
    
    public override func insertOne(_ collection: String, _ doc: [String : Any], _ options: InsertOptions) -> Promise<InsertResult> {
        return DispatchQueue.global().async(.promise){ [self] in
            let edoc = try self._databaseEncrypt.encryptDoc(doc) as! [ String: Any]
            return try self._controller.insertMany(collection, [edoc], options)!
        }
    }
    
    public override func insertMany(_ collection: String, _ docs: Array<[String : Any]>, _ options: InsertOptions) -> Promise<InsertResult> {
        return DispatchQueue.global().async(.promise){ [self] in
            let edoc = try self._databaseEncrypt.encryptDocs(docs) as! Array<[String : Any]>
            return try self._controller.insertMany(collection, edoc, options)!
        }
    }
    
    public override func countDocuments(_ collection: String, _ query: [String : Any], _ options: CountOptions) -> Promise<Int64> {
        return DispatchQueue.global().async(.promise){ [self] in
            let equery = try self._databaseEncrypt.encryptFilter(query) as! [String: Any]
            return try _controller.countDocuments(collection, equery, options)!
        }
    }
    
    public override func findOne(_ collection: String, _ query: [String : Any], _ options: FindOptions) -> Promise<Dictionary<String, Any>> {
        return DispatchQueue.global().async(.promise){ [self] in
            let equery = try self._databaseEncrypt.encryptFilter(query) as! [String: Any]
            let result = try _controller.encryptFind(collection, equery, options)
            if (result.isEncrypt == nil || result.isEncrypt == false ) {
                throw DIDError.UncheckedError.IllegalArgumentErrors.IllegalArgumentError("Cannot decrypt the documents from the encryption collection.")
            }
            let items = result.documents!
            let dencryptItems = try _databaseEncrypt.encryptDocs(items, isEncrypt: false) as! [[String: Any]]
            return dencryptItems.count > 0 ? dencryptItems[0] : [: ]
        }
    }
    
    public override func findMany(_ collection: String, _ query: [String : Any], _ options: FindOptions) -> Promise<[[String: Any]]> {
        return DispatchQueue.global().async(.promise){ [self] in
            let equery = try self._databaseEncrypt.encryptFilter(query) as! [String: Any]
            let result = try self._controller.encryptFind(collection, equery, options)

            if (result.isEncrypt == nil || result.isEncrypt == false ) {
                throw DIDError.UncheckedError.IllegalArgumentErrors.IllegalArgumentError("Cannot decrypt the documents from the encryption collection.")
            }
            let items = result.documents!
            return try _databaseEncrypt.encryptDocs(items, isEncrypt: false) as! [[String: Any]]
        }
    }

    public override func query(_ collection: String, _ query: Dictionary<String, Any>?, _ options: QueryOptions?) -> Promise<Array<Dictionary<String, Any>>> {
        return DispatchQueue.global().async(.promise){ [self] in
            let query_ = query != nil ? query : [: ]
            let equery = try self._databaseEncrypt.encryptFilter(query_!) as! [String: Any]
            let result = try self._controller.encryptquery(collection, equery, options)
            if (result.isEncrypt == nil || result.isEncrypt == false ) {
                throw DIDError.UncheckedError.IllegalArgumentErrors.IllegalArgumentError("Cannot decrypt the documents from the encryption collection.")
            }
            let items = result.documents!
            return try _databaseEncrypt.encryptDocs(items, isEncrypt: false) as! [[String: Any]]
        }
    }

    public override func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], _ options: UpdateOptions) -> Promise<UpdateResult> {
        return DispatchQueue.global().async(.promise){ [self] in
            let filter_ = try self._databaseEncrypt.encryptFilter(filter) as! [String : Any]
            let update_ = try self._databaseEncrypt.encryptUpdate(update) as! [String : Any]
            return try _controller.updateOne(collection, filter_, update_, options)!
        }
    }
    

    public override func updateMany(_ collection: String, _ filter: [String : Any], _ update: [String : Any], _ options: UpdateOptions) -> Promise<UpdateResult> {
        return DispatchQueue.global().async(.promise){ [self] in
            let filter_ = try self._databaseEncrypt.encryptFilter(filter) as! [String : Any]
            let update_ = try self._databaseEncrypt.encryptUpdate(update) as! [String : Any]
            return try _controller.updateMany(collection, filter_, update_, options)!
        }
    }
    
    public override func deleteOne(_ collection: String, _ filter: [String : Any]) -> Promise<Void> {
        return Promise<Void> { resolver in
            let filter_ = try self._databaseEncrypt.encryptFilter(filter) as! [String : Any]
            do {
                _ = try _controller.deleteOne(collection, filter_)
                resolver.fulfill(Void())
            } catch {
                resolver.reject(error)
            }
        }
    }
    
    public override func deleteMany(_ collection: String, _ filter: [String : Any]) -> Promise<Void> {
        return Promise<Void> { resolver in
            do {
                let filter_ = try self._databaseEncrypt.encryptFilter(filter) as! [String : Any]
                _ = try _controller.deleteMany(collection, filter_)
                resolver.fulfill(Void())
            } catch {
                resolver.reject(error)
            }
        }
    }
}
