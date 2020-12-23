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
    
//    /// Lets the vault owner create a collection on database.
//    /// - Parameter name: the collection name
//    /// - Return: fail(false) or success(true)
//    func createCollection(_ name: String) -> Promise<Bool>
//
    /// Lets the vault owner create a collection on database.
    /// - Parameters:
    ///   - name: the collection name
    ///   - options: the collection options
    ///   - Return: fail(false) or success(true)
    func createCollection(_ name: String, options: CreateCollectionOptions?) -> Promise<Bool>


    /// Lets the vault owner delete a collection on database according to collection name.
    /// - Parameter name: the collection name
    ///   - Return: fail(false) or success(true)
    func deleteCollection(_ name: String) -> Promise<Bool>

    /// Insert a new document in a given collection
    /// - Parameters:
    ///   - collection: the collection name
    ///   - doc: The document to insert. Must be a mutable mapping type. If
    ///          the document does not have an _id field one will be added automatically
    ///   - options: bypass_document_validation: (optional) If True, allows
    ///              the write to opt-out of document level validation. Default is False.
    ///   - Return: InsertOneResult instance
    func insertOne(_ collection: String, _ doc: [String: Any], options: InsertOptions?) -> Promise<InsertOneResult>

    /// Insert many new documents in a given collection
    /// - Parameters:
    ///   - collection: the collection name
    ///   - docs: The document to insert. Must be a mutable mapping type. If the
    ///           document does not have an _id field one will be added automatically.
    ///   - options: ordered (optional): If True (the default) documents will be inserted on the server serially,
    ///              in the order provided. If an error occurs all remaining inserts are aborted. If False, documents will be inserted on the server in arbitrary order, possibly in parallel,
    ///              and all document inserts will be attempted.
    ///              bypass_document_validation: (optional) If True, allows the write to opt-out of document level validation. Default is False.
    ///   - Return: InsertManyResult instance
    func insertMany(_ collection: String, _ docs: Array<[String: Any]>, options: InsertOptions) -> Promise<InsertManyResult>

    /// Count documents
    /// - Parameters:
    ///   - collection: the collection name
    ///   - query: The document of filter
    ///   - options: skip (int): The number of matching documents to skip before returning results.
    ///              limit (int): The maximum number of documents to count. Must be a positive integer.
    ///              If not provided, no limit is imposed.
    ///              maxTimeMS (int): The maximum amount of time to allow this operation to run, in milliseconds.
    ///   - Return: document count
    func countDocuments(_ collection: String, _ query: [String: Any], options: CountOptions) -> Promise<Int>

    /// Find a specific document
    /// - Parameters:
    ///   - collection: the collection name
    ///   - query: query optional, a JSON object specifying elements which must be present for a document to be included in the result set
    ///   - options: FindOptions instance
    ///   - Return: a Dictionary object document result
    func findOne(_ collection: String, _ query: [String: Any], options: FindOptions) -> Promise<[String: Any]?>

    /// Find many documents
    /// - Parameters:
    ///   - collection: the collection name
    ///   - query: a JSON object specifying elements which must be present for a document to be included in the result set
    ///   - options: FindOptions instance
    ///   - Return: a Dictionary array result of document
    func findMany(_ collection: String, _ query: [String: Any], options: FindOptions) -> Promise<Array<[String: Any]>?>

    /// Update an existing document in a given collection
    /// - Parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to update.
    ///   - update: The modifications to apply
    ///   - options: UpdateOptions instance
    ///   - Return: UpdateResult instance
    func updateOne(_ collection: String, _ filter: [String: Any], _ update: [String: Any], options: UpdateOptions) -> Promise<UpdateResult>

    /// Update many existing documents in a given collection
    /// - Parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to update.
    ///   - update: The modifications to apply.
    ///   - options: UpdateOptions instance
    ///   - Return: UpdateResult instance
    func updateMany(_ collection: String, _ filter: [String: Any], _ update: [String: Any], options: UpdateOptions) -> Promise<UpdateResult>

    /// Delete an existing document in a given collection
    /// - Parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to delete.
    ///   - options: DeleteOptions instance
    ///   - Return: DeleteResult instance
    func deleteOne(_ collection: String, _ filter: [String: Any], options: DeleteOptions) -> Promise<DeleteResult>

    /// Delete many existing documents in a given collection
    /// - Parameters:
    ///   - collection: the collection name
    ///   - filter: A query that matches the document to delete.
    ///   - options: DeleteOptions instance
    ///   - Return: DeleteResult instance
    func deleteMany(_ collection: String, _ filter: [String: Any], options: DeleteOptions) -> Promise<DeleteResult>
}
