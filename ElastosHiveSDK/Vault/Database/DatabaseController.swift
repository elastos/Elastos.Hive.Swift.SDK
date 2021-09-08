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

/// The wrapper class is to access the database module of the hive node.
public class DatabaseController {
    private var _connectionManager: ConnectionManager
    
    /// Create by the Service endpoint.
    /// - Parameter serviceEndpoint: The Service endpoint.
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _connectionManager = serviceEndpoint.connectionManager!
    }

    /// Create the collection.
    /// - Parameter collectionName: The name of the collection.
    /// - Throws: HiveError The error comes from the hive node.
    public func createCollection(_ collectionName: String) throws {
        var result: CreateCollectionResult? = nil

        result = try _connectionManager.createCollection(collectionName).execute(CreateCollectionResult.self)
        if collectionName != result?.name  {
            throw HiveError.ServerUnkownException("Different collection created, impossible to happen")
        }
    }

    /// Delete the collection by name.
    /// - Parameter collectionName: The name of the collection.
    /// - Throws: HiveError The error comes from the hive node.
    public func deleteCollection(_ collectionName: String) throws {
        _ = try _connectionManager.deleteCollection(collectionName).execute()
    }

    public static func jsonNode2Str(_ dic: Dictionary<String, Any>?) -> String? {
        let data = try? JSONSerialization.data(withJSONObject: dic as Any, options: [])
        let str = String(data: data!, encoding: String.Encoding.utf8)
        return str
    }

    /// Insert one document.
    /// - Parameters:
    ///   - collectionName: The name of the collection.
    ///   - document: The document.
    ///   - options: Insert options.
    /// - Throws: The details of the insert operation.
    /// - Returns: HiveError The error comes from the hive node.
    public func insertOne(_ collectionName: String, _ document: Dictionary<String, Any>, _ options: InsertOptions?) throws -> InsertResult? {
        return try insertMany(collectionName, [document], options)
    }

    /// Insert many documents.
    /// - Parameters:
    ///   - collectionName: The name of the collection.
    ///   - documents: The document.
    ///   - options: Insert options.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The details of the insert operation.
    public func insertMany(_ collectionName: String, _ documents: [Dictionary<String, Any>]?, _ options: InsertOptions?) throws -> InsertResult? {
        return try _connectionManager.insert(collectionName, InsertParams(documents, options)).execute(InsertResult.self)
    }

    /// Update the first matched document by the filter.
    /// - Parameters:
    ///   - collectionName: The name of the collection.
    ///   - filter: The filter to filter the matched document.
    ///   - update: The update data.
    ///   - options: The update options.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The details of the update operation.
    public func updateOne(_ collectionName: String, _ filter: Dictionary<String, Any>?, _ update: Dictionary<String, Any>?, _ options: UpdateOptions) throws -> UpdateResult? {
        return try _connectionManager.update(collectionName, UpdateParams(filter, update, options), true).execute(UpdateResult.self)
    }

    /// Update all matched documents by the filter.
    /// - Parameters:
    ///   - collectionName: The name of the collection.
    ///   - filter: The filter to filter the matched document.
    ///   - update: The update data.
    ///   - options: The update options.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The details of the update operation.
    public func updateMany(_ collectionName: String, _ filter: Dictionary<String, Any>?, _ update: Dictionary<String, Any>?, _ options: UpdateOptions) throws -> UpdateResult? {
        return try _connectionManager.update(collectionName, UpdateParams(filter, update, options), false).execute(UpdateResult.self)
    }

    /// Delete the first matched document by the filter.
    /// - Parameters:
    ///   - collectionName: The name of the collection.
    ///   - filter: The filter to filter the matched document.
    /// - Returns: The details of the delete operation.
    public func deleteOne(_ collectionName: String, _ filter: Dictionary<String, Any>?) throws -> DeleteResult? {
        try _connectionManager.delete(collectionName, DeleteParams(filter, nil), true).execute(DeleteResult.self)
    }

    /// Delete all matched document by the filter.
    /// - Parameters:
    ///   - collectionName: The name of the collection.
    ///   - filter: The filter to filter the matched documents.
    /// - Returns: The details of the delete operation.
    public func deleteMany(_ collectionName: String, _ filter: Dictionary<String, Any>?) throws -> DeleteResult? {
        return try _connectionManager.delete(collectionName, DeleteParams(filter, nil), false).execute(DeleteResult.self)
    }

    /// Count the documents by filter.
    /// - Parameters:
    ///   - collectionName: The name of the collection.
    ///   - filter: The filter to match the documents.
    ///   - options: Count options.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The number of the matched documents.
    public func countDocuments(_ collectionName: String, _ filter: Dictionary<String, Any>?, _ options: CountOptions) throws -> Int64? {
        return try _connectionManager.count(collectionName, CountParams(filter, options)).execute(CountResult.self).count
    }
    
    /// Find the first matched document by filter.
    /// - Parameters:
    ///   - collectionName: The name of the collection.
    ///   - filter: The filter to match the document.
    ///   - options: The find options.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The first matched document for the find operation.
    public func findOne(_ collectionName: String, _ filter: Dictionary<String, Any>?, _ options: FindOptions?) throws -> Dictionary<String, Any>? {
        let docs = try find(collectionName, filter, options)
        return docs?.first
    }

    /// Find all matched document by filter.
    /// - Parameters:
    ///   - collectionName: The name of the collection.
    ///   - filter: The filter to match the documents.
    ///   - options: The find options.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: All matched documents for the find operation.
    public func find(_ collectionName: String, _ filter: Dictionary<String, Any>?, _ options: FindOptions?) throws -> Array<Dictionary<String, Any>>? {
        let skip: String = (options != nil ? options!.getSkipStr() : "")
        let limit: String = (options != nil ? options!.getLimitStr() : "")
        
        return try _connectionManager.find(collectionName, (DatabaseController.jsonNode2Str(filter)?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!, skip, limit).execute(FindResult.self).documents
    }

    /// Query the documents by filter and options.
    /// - Parameters:
    ///   - collectionName: The name of the collection.
    ///   - filter: The filter to match the documents.
    ///   - options: The query options.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: All matched documents for the query operation.
    public func query(_ collectionName: String, _ filter: Dictionary<String, Any>?, _ options: QueryOptions?) throws -> Array<Dictionary<String, Any>>? {
        return try _connectionManager.query(QueryParams(collectionName, filter, options)).execute(QueryResult.self).documents
    }
}
