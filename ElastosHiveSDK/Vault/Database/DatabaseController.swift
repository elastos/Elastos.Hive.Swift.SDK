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

//    public DatabaseController(NodeRPCConnection connection) {
//        databaseAPI = connection.createService(DatabaseAPI.class, true);
//    }
    public func createCollection(_ collectionName: String?) throws {
        // TODO
    }
    
    public func deleteCollection(_ collectionName: String?) throws {
        // TODO
    }

    public static func jsonNode2Str(_ dic: Dictionary<String, Any>?) -> String? {
        // TODO
        return nil
    }

    public func insertOne(_ collectionName: String?, _ document: Dictionary<String, Any>?, _ options: InsertOptions?) throws -> InsertResult? {
        return try insertMany(collectionName, [document], options)
    }
    
    public func insertMany(_ collectionName: String?, _ document: [Dictionary<String, Any>?]?, _ options: InsertOptions?) throws -> InsertResult? {
        // TODO
        return nil
    }
    
    public func updateOne(_ collectionName: String?, _ filter: Dictionary<String, Any>?, _ update: Dictionary<String, Any>?, _ options: UpdateOptions) throws -> InsertResult? {
        throw HiveError.NotImplementedException
    }
    
    

//    public UpdateResult updateOne(String collectionName, JsonNode filter,
//                                  JsonNode update, UpdateOptions options) throws HiveException {
//        throw new NotImplementedException();
//    }
//
//    public UpdateResult updateMany(String collectionName, JsonNode filter,
//                                   JsonNode update,
//                                   UpdateOptions options) throws HiveException {
//        try {
//            return databaseAPI.update(collectionName, new UpdateParams(filter, update, options)).execute().body();
//        } catch (NodeRPCException e) {
//            // TODO:
//            throw new ServerUnkownException(e);
//        } catch (IOException e) {
//            throw new NetworkException(e);
//        }
//    }
//
//    public int deleteOne(String collection, JsonNode filter, DeleteOptions options) throws HiveException {
//        throw new NotImplementedException();
//    }
//
//    public int deleteMany(String collectionName, JsonNode filter, DeleteOptions options) throws HiveException {
//        try {
//            // TODO:
//            databaseAPI.delete(collectionName, new DeleteParams(filter, options)).execute().body();
//            return 0;
//        } catch (NodeRPCException e) {
//            // TODO:
//            throw new ServerUnkownException(e);
//        } catch (IOException e) {
//            throw new NetworkException(e);
//        }
//    }
//
//    public long countDocuments(String collectionName, JsonNode filter, CountOptions options) throws HiveException {
//        try {
//            return databaseAPI.count(collectionName, new CountParams(filter, options))
//                    .execute().body().getCount();
//        } catch (NodeRPCException e) {
//            // TODO:
//            throw new ServerUnkownException(e);
//        } catch (IOException e) {
//            throw new NetworkException(e);
//        }
//    }
//
//    public JsonNode findOne(String collectionName, JsonNode filter, FindOptions options) throws HiveException {
//        List<JsonNode> docs = find(collectionName, filter, options);
//        return docs != null && !docs.isEmpty() ? docs.get(0) : null;
//    }
//
//    public List<JsonNode> find(String collectionName, JsonNode filter, FindOptions options) throws HiveException {
//        try {
//            String skip = options != null ? options.getSkipStr() : "";
//            String limit = options != null ? options.getLimitStr() : "";
//            return databaseAPI.find(collectionName, jsonNode2Str(filter), skip, limit)
//                        .execute().body().documents();
//        } catch (NodeRPCException e) {
//            // TODO:
//            throw new ServerUnkownException(e);
//        } catch (IOException e) {
//            throw new NetworkException(e);
//        }
//    }
//
//    public List<JsonNode> query(String collectionName, JsonNode filter, QueryOptions options) throws HiveException {
//        try {
//            return databaseAPI.query(new QueryParams(collectionName, filter, options)).execute().body().documents();
//        } catch (NodeRPCException e) {
//            // TODO:
//            throw new ServerUnkownException(e);
//        } catch (IOException e) {
//            throw new NetworkException(e);
//        }
//    }
}
