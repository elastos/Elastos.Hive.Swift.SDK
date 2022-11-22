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

import XCTest
@testable import ElastosHiveSDK
import DeveloperDID
import AwaitKit

class DatabaseEncryptionTest: XCTestCase {
    private let COLLECTION_NAME = "encrypt_works_2"
    private let COLLECTION_NAME_NOT_EXIST = "works_not_exists"
    private var _vaultSubscription: VaultSubscription!
    private var _databaseService: DatabaseService?
    
    override func setUp() {
        Log.setLevel(.Debug)
        let testData = TestData.shared()
        XCTAssertNoThrow(_vaultSubscription = try VaultSubscription(testData.appContext, testData.providerAddress))

        XCTAssertNoThrow(_databaseService = try testData.getEncryptionDatabaseService())
        do {
            try `await`(_vaultSubscription.subscribe())
        } catch  {
            if let error = error as? HiveError {
                switch error {
                case .AlreadyExistsException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    func test01CreateCollection() {
        XCTAssertNoThrow(try { [self] in
            do {
                try `await`(_databaseService!.deleteCollection(COLLECTION_NAME))
            }catch {
                
            }
            try `await`(_databaseService!.createCollection(COLLECTION_NAME))
        }())
    }
    
    func test02InsertOne() {
        XCTAssertNoThrow(try { [self] in
            let docNode = ["author" : "john doe", "title" : "Eve for Dummies3", "words_count": 10000, "published": true] as [String : Any]
            XCTAssertNotNil(try `await`(_databaseService!.insertOne(COLLECTION_NAME, docNode, InsertOptions().bypassDocumentValidation(false).timestamp(true))))
            let filter = ["author" : "john doe"]
            let docs = try `await`(_databaseService!.findMany(COLLECTION_NAME, filter, FindOptions().setSkip(0).setLimit(0)))
            print(docs)
        }())
    }
    
    public func test03testUpdateAndFindMany() {
        XCTAssertNoThrow(try { [self] in
            let filter = ["author" : "john doe"]
            let updateNode = ["$set": [ "title": "Eve for Dummies4" ]]
            let re = try `await`(_databaseService!.updateOne(COLLECTION_NAME, filter, updateNode, UpdateOptions().setUpsert(true).setBypassDocumentValidation(false)))
            print(re)
            let docs = try `await`(_databaseService!.findMany(COLLECTION_NAME, filter, FindOptions().setSkip(0).setLimit(0)))
            print(docs)
        }())
    }
    
    public func test04FindMany() {
        XCTAssertNoThrow(try { [self] in
            let filter = ["author" : "john doe"]
            let docs = try `await`(_databaseService!.findMany(COLLECTION_NAME, filter, FindOptions().setSkip(0).setLimit(0)))
            print(docs)
        }())
    }
}
