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

public class DatabaseServiceRender: DatabaseService {
    public let _controller: DatabaseController
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _controller = DatabaseController(serviceEndpoint)
    }
    
    /// Lets the vault owner create a collection on database.
    /// - Parameter name: the collection name
    /// - Returns: fail(false) or success(true)
    public func createCollection(_ name: String) -> Promise<Void> {
        DispatchQueue.global().async(.promise) { [self] in
            return try _controller.createCollection(name)
        }
    }

    /// Lets the vault owner delete a collection on database according to collection name.
    /// - Parameter name: the collection name
    /// - Returns: fail(false) or success(true)
    public func deleteCollection(_ name: String) -> Promise<Void> {
        DispatchQueue.global().async(.promise) { [self] in
            return try _controller.deleteCollection(name)
        }
    }

    /// Insert a new document in a given collection.
    /// - Parameters:
    ///   - collection: the collection name
    ///   - doc: The document to insert. Must be a mutable mapping type. If
    ///          the document does not have an _id field one will be added automatically
    ///   - options: bypass_document_validation: (optional) If True, allows
    ///              the write to opt-out of document level validation. Default is False.
    /// - Returns: InsertResult
    public func insertOne(_ collection: String, _ doc: [String : Any], _ options: InsertOptions) -> Promise<InsertResult> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.insertOne(collection, doc, options)!
        }
    }
    
    /// Insert many new documents in a given collection.
    /// - Parameters:
    ///   - collection: the collection name
    ///   - docs: The document to insert. Must be a mutable mapping type. If the
    ///           document does not have an _id field one will be added automatically.
    ///   - options: ordered (optional): If True (the default) documents will be inserted on the server serially,
    ///              in the order provided. If an error occurs all remaining inserts are aborted. If False, documents
    ///              will be inserted on the server in arbitrary order, possibly in parallel, and all document inserts will be attempted.
    ///              bypass_document_validation: (optional) If True, allows the write to opt-out of document level validation. Default is False.
    /// - Returns: InsertResult
    public func insertMany(_ collection: String, _ docs: [Dictionary<String, Any>], _ options: InsertOptions) -> Promise<InsertResult> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.insertMany(collection, docs, options)!
        }
    }

    /// Count documents.
    /// - Parameters:
    ///   - collection: the collection name
    ///   - query: The document of filter
    ///   - options: skip (int): The number of matching documents to skip before returning results.
    ///              limit (int): The maximum number of documents to count. Must be a positive integer. If not provided, no limit is imposed.
    ///              maxTimeMS (int): The maximum amount of time to allow this operation to run, in milliseconds.
    /// - Returns: count size
    public func countDocuments(_ collection: String, _ query: [String : Any], _ options: CountOptions) -> Promise<Int64> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.countDocuments(collection, query, options)!
        }
    }

    /// Find a specific document.
    /// - Parameters:
    ///   - collection: the collection name
    ///   - query: optional, a JSON object specifying elements which must be present for a document to be included in the result set
    ///   - options: optional,refer to FindOptions
    /// - Returns: a Dictionary object document result
    public func findOne(_ collection: String, _ query: [String : Any], _ options: FindOptions) -> Promise<Dictionary<String, Any>> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.findOne(collection, query, options)!
        }
    }

    /// Find many documents.
    /// - Parameters:
    ///   - collection: the collection name
    ///   - query: optional, a JSON object specifying elements which must be present for a document to be included in the result set
    ///   - options: optional,refer to FindOptions
    /// - Returns: a Dictionary array result of document
    public func findMany(_ collection: String, _ query: [String : Any], _ options: FindOptions) -> Promise<Array<Dictionary<String, Any>>> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.find(collection, query, options)!
        }
    }
    
    /// Find many documents by many options.
    /// - Parameters:
    ///   - collection: the collection name
    ///   - query: optional, a JSON object specifying elements which must be present for a document to be included in the result set
    ///   - options: optional,refer to QueryOptions
    /// - Returns: a Dictionary array result of document
    public func query(_ collection: String, _ query: Dictionary<String, Any>?, _ options: QueryOptions?) -> Promise<Array<Dictionary<String, Any>>> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.query(collection, query, options)!
        }
    }
    
    /// Update an existing document in a given collection.
    /// - Parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to update.
    ///   - update: The modifications to apply.
    ///   - options: optional, refer to UpdateOptions
    /// - Returns: UpdateResult
    public func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], _ options: UpdateOptions) -> Promise<UpdateResult> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.updateOne(collection, filter, update, options)!
        }
    }

    /// Update many existing documents in a given collection.
    /// - Parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to update.
    ///   - update: The modifications to apply.
    ///   - options: optional, refer to UpdateOptions
    /// - Returns: UpdateResult
    public func updateMany(_ collection: String, _ filter: [String : Any], _ update: [String : Any], _ options: UpdateOptions) -> Promise<UpdateResult> {
        return Promise<UpdateResult> { resolver in
            do {
                resolver.fulfill(try _controller.updateMany(collection, filter, update, options)!)
            } catch {
                resolver.reject(error)
            }
        }
    }

    /// Delete an existing document in a given collection.
    /// - Parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to delete.
    /// - Returns: Void
    public func deleteOne(_ collection: String, _ filter: [String : Any]) -> Promise<Void> {
        return Promise<Void> { resolver in
            do {
                _ = try _controller.deleteOne(collection, filter)
                resolver.fulfill(Void())
            } catch {
                resolver.reject(error)
            }
        }
    }

    /// Delete many existing documents in a given collection.
    /// - Parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to delete.
    /// - Returns: Void
    public func deleteMany(_ collection: String, _ filter: [String : Any]) -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            _ = try _controller.deleteMany(collection, filter)
        }
    }
}
