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

/**
 * Mongo database service.
 * TODO: refine APIs like *One, *Many, find*.
 */
public protocol DatabaseService {
    
    /// Lets the vault owner create a collection on database.
    ///
    /// - parameters:
    ///    - name: the collection name
    /// - returns: fail(false) or success(true)
    func createCollection(_ name: String) -> Promise<Void>

    /// Lets the vault owner delete a collection on database according to collection name.
    ///
    /// - parameters:
    ///    - name: the collection name
    /// - returns fail(false) or success(true)
    func deleteCollection(_ name: String) -> Promise<Void>

    /// Insert a new document in a given collection
    /// - parameters:
    ///   - collection: the collection name
    ///   - doc: The document to insert. Must be a mutable mapping type. If
    ///          the document does not have an _id field one will be added automatically
    ///   - options: bypass_document_validation: (optional) If True, allows
    ///              the write to opt-out of document level validation. Default is False.
    /// - returns: Results returned by InsertResult wrapper
    func insertOne(_ collection: String, _ doc: [String: Any], _ options: InsertOptions) -> Promise<InsertResult>
  
    /// Insert many new documents in a given collection
    ///
    /// - parameters:
    ///   - collection: the collection name
    ///   - docs: The document to insert. Must be a mutable mapping type. If the
    ///           document does not have an _id field one will be added automatically.
    ///   - options: ordered (optional): If True (the default) documents will be inserted on the server serially,
    ///              in the order provided. If an error occurs all remaining inserts are aborted. If False, documents will be inserted on the server in arbitrary order, possibly in parallel,
    ///              and all document inserts will be attempted.
    ///              bypass_document_validation: (optional) If True, allows the write to opt-out of document level validation. Default is False.
    /// - returns: Results returned by `InsertResult` wrapper
    func insertMany(_ collection: String, _ docs: Array<[String: Any]>,_ options: InsertOptions) -> Promise<InsertResult>
    
    /// Count documents
    ///
    /// - parameters:
    ///   - collection: the collection name
    ///   - query: The document of filter
    ///   - options:
    ///     - skip (int): The number of matching documents to skip before returning results.
    ///     - limit (int): The maximum number of documents to count. Must be a positive integer. If not provided, no limit is imposed.
    ///     - maxTimeMS (int): The maximum amount of time to allow this operation to run, in milliseconds.
    ///  - returns: count size
    func countDocuments(_ collection: String, _ query: [String: Any], _ options: CountOptions) -> Promise<Int64>
    
    /// Find a specific document
    ///
    /// - parameters:
    ///   - collection the collection name
    ///   - query: query optional, a JSON object specifying elements which must be present for a document to be included in the result set
    ///   - options: options optional,refer to {@link FindOptions}
    ///  - returns: a Dictionary object document result
    func findOne(_ collection: String, _ query: [String: Any], _ options: FindOptions) -> Promise<Dictionary<String, Any>>

    /// Find many documents
    /// - Parameters:
    ///   - collection: the collection name
    ///   - query: a JSON object specifying elements which must be present for a document to be included in the result set
    ///   - options: FindOptions instance
    ///  - returns: a Dictionary array result of document
    func findMany(_ collection: String, _ query: [String: Any], _ options: FindOptions) -> Promise<Array<Dictionary<String, Any>>>
    
    /// Find many documents by many options.
    /// - Parameters:
    ///   - collection: the collection name
    ///   - query: query optional, a JSON object specifying elements which must be present for a document to be included in the result set
    ///   - options: optional,refer to QueryOptions
    ///  - returns: a Dictionary array result of document
    func query(_ collection: String, _ query: Dictionary<String, Any>?, _ options: QueryOptions?) -> Promise<Array<Dictionary<String, Any>>>

    /// Update an existing document in a given collection
    ///
    /// - parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to update.
    ///   - update: The modifications to apply
    ///   - options: UpdateOptions instance
    ///
    /// - returns: Results returned by `UpdateResult` wrapper
    func updateOne(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions) -> Promise<UpdateResult>

    /// Update many existing documents in a given collection
    ///
    /// - parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to update.
    ///   - update: The modifications to apply.
    ///   - options: optional, refer to UpdateOptions
    ///
    /// - returns: returned by UpdateResult wrapper
    func updateMany(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions) -> Promise<UpdateResult>

    /// Delete an existing document in a given collection.
    /// 
    /// - parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to delete.
    ///
    /// - returns: Delete result
    func deleteOne(_ collection: String, _ filter: [String: Any]) -> Promise<Void>

    /// Delete many existing documents in a given collection.
    ///
    /// - parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to delete.
    ///   - options:
    ///
    /// - returns: Delete result
    func deleteMany(_ collection: String, _ filter: [String: Any]) -> Promise<Void>
}
