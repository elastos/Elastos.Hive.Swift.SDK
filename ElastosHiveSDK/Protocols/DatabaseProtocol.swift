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

    func createCollection(_ name: String) -> HivePromise<Bool>
    func createCollection(_ name: String, options: CreateCollectionOptions) -> HivePromise<Bool>

    func deleteCollection(_ name: String) -> HivePromise<Bool>

    func insertOne(_ collection: String, _ doc: [String: Any], options: InsertOptions?) -> HivePromise<InsertOneResult>

    func insertMany(_ collection: String, _ docs: Array<[String: Any]>, options: InsertOptions) -> HivePromise<InsertManyResult>

    func countDocuments(_ collection: String, _ query: [String: Any], options: CountOptions) -> HivePromise<Int>

    func findOne(_ collection: String, _ query: [String: Any], options: FindOptions) -> HivePromise<[String: Any]>

    func findMany(_ collection: String, _ query: [String: Any], options: FindOptions) -> HivePromise<Array<[String: Any]>>

    func updateOne(_ collection: String, _ filter: [String: Any], _ update: [String: Any], options: UpdateOptions) -> HivePromise<UpdateResult>

    func updateMany(_ collection: String, _ filter: [String: Any], _ update: [String: Any], options: UpdateOptions) -> HivePromise<UpdateResult>

    func deleteOne(_ collection: String, _ filter: [String: Any], options: DeleteOptions) -> HivePromise<DeleteResult>

    func deleteMany(_ collection: String, _ filter: [String: Any], options: DeleteOptions) -> HivePromise<DeleteResult>
}
