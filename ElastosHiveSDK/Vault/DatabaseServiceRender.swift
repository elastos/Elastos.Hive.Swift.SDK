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
    
    public func createCollection(_ name: String) -> Promise<Void> {
        DispatchQueue.global().async(.promise) { [self] in
            return try _controller.createCollection(name)
        }
    }

    public func deleteCollection(_ name: String) -> Promise<Void> {
        DispatchQueue.global().async(.promise) { [self] in
            return try _controller.deleteCollection(name)
        }
    }

    public func insertOne(_ collection: String, _ doc: [String : Any], _ options: InsertOptions) -> Promise<InsertResult> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.insertOne(collection, doc, options)!
        }
    }
    
    public func insertMany(_ collection: String, _ docs: [Dictionary<String, Any>], _ options: InsertOptions) -> Promise<InsertResult> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.insertMany(collection, docs, options)!
        }
    }

    public func countDocuments(_ collection: String, _ query: [String : Any], _ options: CountOptions) -> Promise<Int64> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.countDocuments(collection, query, options)!
        }
    }

    public func findOne(_ collection: String, _ query: [String : Any], _ options: FindOptions) -> Promise<Dictionary<String, Any>> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.findOne(collection, query, options)!
        }
    }

    public func findMany(_ collection: String, _ query: [String : Any], _ options: FindOptions) -> Promise<Array<Dictionary<String, Any>>> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.find(collection, query, options)!
        }
    }
    
    public func query(_ collection: String, _ query: Dictionary<String, Any>?, _ options: QueryOptions?) -> Promise<Array<Dictionary<String, Any>>> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.query(collection, query, options)!
        }
    }
    
    public func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], _ options: UpdateOptions) -> Promise<UpdateResult> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.updateOne(collection, filter, update, options)!
        }
    }

    public func updateMany(_ collection: String, _ filter: [String : Any], _ update: [String : Any], _ options: UpdateOptions) -> Promise<UpdateResult> {
        return Promise<UpdateResult> { resolver in
            do {
                resolver.fulfill(try _controller.updateMany(collection, filter, update, options)!)
            } catch {
                resolver.reject(error)
            }
        }
    }

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

    public func deleteMany(_ collection: String, _ filter: [String : Any]) -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            _ = try _controller.deleteMany(collection, filter)
//            return 
//            return Promise<Void> { resolver in
//                do {
//                    _ = try _controller.deleteMany(collection, filter)
//                    resolver.fulfill(Void())
//                } catch {
//                    resolver.reject(error)
//                }
//            }
        }
    }
}
