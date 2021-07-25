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

public class DatabaseController {
    private var _connectionManager: ConnectionManager
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _connectionManager = serviceEndpoint.connectionManager!
    }

    public func createCollection(_ collectionName: String) throws {
        var result: CreateCollectionResult? = nil

        result = try _connectionManager.createCollection(collectionName).execute(CreateCollectionResult.self)
        if collectionName != result?.name  {
            throw HiveError.ServerUnkownException("Different collection created, impossible to happen")
        }
    }

    public func deleteCollection(_ collectionName: String) throws {
        _ = try _connectionManager.deleteCollection(collectionName).execute()
    }

    public static func jsonNode2Str(_ dic: Dictionary<String, Any>?) -> String? {
        let data = try? JSONSerialization.data(withJSONObject: dic as Any, options: [])
        let str = String(data: data!, encoding: String.Encoding.utf8)
        return str
    }

    public func insertOne(_ collectionName: String, _ document: Dictionary<String, Any>, _ options: InsertOptions?) throws -> InsertResult? {
        return try insertMany(collectionName, [document], options)
    }

    public func insertMany(_ collectionName: String, _ documents: [Dictionary<String, Any>]?, _ options: InsertOptions?) throws -> InsertResult? {
        return try _connectionManager.insert(collectionName, InsertParams(documents, options)).execute(InsertResult.self)
    }

    public func updateOne(_ collectionName: String, _ filter: Dictionary<String, Any>?, _ update: Dictionary<String, Any>?, _ options: UpdateOptions) throws -> UpdateResult? {
        throw HiveError.NotImplementedException("")
    }

    public func updateMany(_ collectionName: String, _ filter: Dictionary<String, Any>?, _ update: Dictionary<String, Any>?, _ options: UpdateOptions) throws -> UpdateResult? {
        return try _connectionManager.update(collectionName, UpdateParams(filter, update, options)).execute(UpdateResult.self)
    }

    public func deleteOne(_ collectionName: String, _ filter: Dictionary<String, Any>?) throws -> DeleteResult? {
        throw HiveError.NotImplementedException("")
    }

    public func deleteMany(_ collectionName: String, _ filter: Dictionary<String, Any>?) throws -> DeleteResult? {
        return try _connectionManager.delete(collectionName, DeleteParams(filter, nil)).execute(DeleteResult.self)
    }

    public func countDocuments(_ collectionName: String, _ filter: Dictionary<String, Any>?, _ options: CountOptions) throws -> Int64? {
        return try _connectionManager.count(collectionName, CountParams(filter, options)).execute(CountResult.self).count
    }
    
    public func findOne(_ collectionName: String, _ filter: Dictionary<String, Any>?, _ options: FindOptions?) throws -> Dictionary<String, Any>? {
        let docs = try find(collectionName, filter, options)
        return docs?.first
    }

    public func find(_ collectionName: String, _ filter: Dictionary<String, Any>?, _ options: FindOptions?) throws -> Array<Dictionary<String, Any>>? {
        let skip: String = (options != nil ? options!.getSkipStr() : "")
        let limit: String = (options != nil ? options!.getLimitStr() : "")
        
        return try _connectionManager.find(collectionName, (DatabaseController.jsonNode2Str(filter)?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!, skip, limit).execute(FindResult.self).documents
    }

    public func query(_ collectionName: String, _ filter: Dictionary<String, Any>?, _ options: QueryOptions?) throws -> Array<Dictionary<String, Any>>? {
        return try _connectionManager.query(QueryParams(collectionName, filter, options)).execute(QueryResult.self).documents
    }
}
