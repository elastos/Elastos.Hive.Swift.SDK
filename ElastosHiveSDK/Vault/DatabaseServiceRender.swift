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
        return Promise<Any>.async().then{ [self] _ -> Promise<InsertResult> in
            return Promise<InsertResult> { resolver in
                do {
                    resolver.fulfill(try _controller.insertOne(collection, doc, options)!)
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func insertMany(_ collection: String, _ docs: [Dictionary<String, Any>], _ options: InsertOptions) -> Promise<InsertResult> {
        return Promise<Any>.async().then{ [self] _ -> Promise<InsertResult> in
            return Promise<InsertResult> { resolver in
                do {
                    resolver.fulfill(try _controller.insertMany(collection, docs, options)!)
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }

    public func countDocuments(_ collection: String, _ query: [String : Any], _ options: CountOptions) -> Promise<Int64> {
        return Promise<Any>.async().then{ [self] _ -> Promise<Int64> in
            return Promise<Int64> { resolver in
                do {
                    resolver.fulfill(try _controller.countDocuments(collection, query, options)!)
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }

    public func findOne(_ collection: String, _ query: [String : Any], _ options: FindOptions) -> Promise<Dictionary<String, Any>> {
        return Promise<Any>.async().then{ [self] _ -> Promise<Dictionary<String, Any>> in
            return Promise<Dictionary<String, Any>> { resolver in
                do {
                    resolver.fulfill(try _controller.findOne(collection, query, options)!)
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }

    public func findMany(_ collection: String, _ query: [String : Any], _ options: FindOptions) -> Promise<Array<Dictionary<String, Any>>> {
        return Promise<Any>.async().then{ [self] _ -> Promise<Array<Dictionary<String, Any>>> in
            return Promise<Array<Dictionary<String, Any>>> { resolver in
                do {
                    resolver.fulfill(try _controller.find(collection, query, options)!)
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func query(_ collection: String, _ query: Dictionary<String, Any>?, _ options: QueryOptions?) -> Promise<Array<Dictionary<String, Any>>> {
        return Promise<Array<Dictionary<String, Any>>> { resolver in
            do {
                resolver.fulfill(try _controller.query(collection, query, options!)!)
            } catch {
                resolver.reject(error)
            }
        }
    }
    
    public func updateOne(_ collection: String, _ filter: [String : Any], _ update: [String : Any], _ options: UpdateOptions) -> Promise<UpdateResult> {
        return Promise<UpdateResult> { resolver in
            do {
                resolver.fulfill(try _controller.updateOne(collection, filter, update, options)!)
            } catch {
                resolver.reject(error)
            }
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
        return Promise<Void> { resolver in
            do {
                _ = try _controller.deleteMany(collection, filter)
                resolver.fulfill(Void())
            } catch {
                resolver.reject(error)
            }
        }
    }
}
