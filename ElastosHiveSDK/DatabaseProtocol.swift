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

public protocol DatabaseProtocol {
    
    /// Lets the vault owner create a collection on database.
    ///
    /// - Parameter name the collection name
    /// - Returns: fail(false) or success(true)
    func createCollection(_ name: String, _ options: CreateCollectionOptions?) -> Promise<Bool>


    /// Lets the vault owner delete a collection on database according to collection name.
    ///
    /// - Parameter name: the collection name
    ///
    /// - Returns fail(false) or success(true)
    func deleteCollection(_ name: String) -> Promise<Bool>

    /// Insert a new document in a given collection
    /// - parameters:
    ///   - collection: the collection name
    ///   - doc: The document to insert. Must be a mutable mapping type. If
    ///          the document does not have an _id field one will be added automatically
    ///   - options: bypass_document_validation: (optional) If True, allows
    ///              the write to opt-out of document level validation. Default is False.
    /// - returns: Results returned by InsertOneResult wrapper
    func insertOne(_ collection: String, _ doc: [String: Any], _ options: InsertOneOptions?) -> Promise<InsertDocResponse>

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
    /// - returns: Results returned by `InsertManyResult` wrapper
    func insertMany(_ collection: String, _ docs: Array<[String: Any]>,_ options: InsertManyOptions) -> Promise<InsertDocsResponse>

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
    ///   - Return: a Dictionary object document result
    func findOne(_ collection: String, _ query: [String: Any], _ options: FindOptions) -> Promise<FindDocResponse>

    /// Find many documents
    /// - Parameters:
    ///   - collection: the collection name
    ///   - query: a JSON object specifying elements which must be present for a document to be included in the result set
    ///   - options: FindOptions instance
    ///   - Return: a Dictionary array result of document
    func findMany(_ collection: String, _ query: [String: Any], _ options: FindOptions) -> Promise<FindDocsResponse>

    /// Update an existing document in a given collection
    ///
    /// - parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to update.
    ///   - update: The modifications to apply
    ///   - options: UpdateOptions instance
    ///
    /// - returns Results returned by `UpdateResult` wrapper
    func updateOne(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions) -> Promise<UpdateResult>

    /// Update many existing documents in a given collection
    ///
    /// - Parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to update.
    ///   - update: The modifications to apply.
    ///   - options: optional, refer to UpdateOptions
    ///
    /// - Returns 
    func updateMany(_ collection: String, _ filter: [String: Any], _ update: [String: Any], _ options: UpdateOptions) -> Promise<UpdateResult>

    /// Delete an existing document in a given collection
    /// 
    /// - Parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to delete.
    ///   - options:
    ///
    /// - Returns
    func deleteOne(_ collection: String, _ filter: [String: Any], options: DeleteOptions) -> Promise<DeleteResult>

    /// Delete many existing documents in a given collection
    ///
    /// - Parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to delete.
    ///   - options:
    ///
    /// - Returns
    func deleteMany(_ collection: String, _ filter: [String: Any], options: DeleteOptions) -> Promise<DeleteResult>
}
