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
import ElastosDIDSDK
import AwaitKit

class DatabaseServiceTest: XCTestCase {
    private let COLLECTION_NAME = "works"
    private var _databaseService: DatabaseService?
    
    override func setUp() {
        XCTAssertNoThrow(_databaseService = TestData.shared().newVault().databaseService)
    }

    func test1CreateCollection() {
        XCTAssertNoThrow(try { [self] in
            XCTAssertNotNil(try await(_databaseService!.createCollection(COLLECTION_NAME)))
        }())
    }
    
    func test2InsertOne() {
        XCTAssertNoThrow({ [self] in
            let docNode = ["author" : "john doe1", "title" : "Eve for Dummies1"]
            XCTAssertNotNil(try await(_databaseService!.insertOne(COLLECTION_NAME, docNode, InsertOptions().bypassDocumentValidation(false))))
        })
    }
    
    public func test03InsertMany() {
        XCTAssertNoThrow({ [self] in
            let nodes = [
                ["author" : "john doe2", "title" : "Eve for Dummies2"],
                ["author" : "john doe3", "title" : "Eve for Dummies3"],
            ]
            XCTAssertNotNil(try await(_databaseService!.insertMany(COLLECTION_NAME, nodes, InsertOptions().bypassDocumentValidation(false).ordered(true))))
        })
    }
    
    public func test04FindOne() {
        XCTAssertNoThrow({ [self] in
            let query = ["author" : "john doe1"]
            XCTAssertNotNil(try await(_databaseService!.findOne(COLLECTION_NAME, query, FindOptions().setSkip(0).setLimit(0))))
        })
    }
  
    public func test05FindMany() {
        XCTAssertNoThrow({ [self] in
            let query = ["author" : "john doe1"]
            XCTAssertNotNil(try await(_databaseService!.findMany(COLLECTION_NAME, query, FindOptions().setSkip(0).setLimit(0))))
        })
    }
    
    public func test06Query() {
        XCTAssertNoThrow({ [self] in
            let query = ["author" : "john doe1"]
            XCTAssertNotNil(try await(_databaseService!.query(COLLECTION_NAME, query, nil)))
        })
    }
    
    public func test06QueryWithOptions() {
        XCTAssertNoThrow({ [self] in
            let query = ["author" : "john doe1"]
            let options = QueryOptions().setSort(AscendingSortItem("_id"))
            XCTAssertNotNil(try await(_databaseService!.query(COLLECTION_NAME, query, options)))
        })
    }
    
    public func test07CountDoc() {
        XCTAssertNoThrow({ [self] in
            let filter = ["author" : "john doe1"]
            XCTAssertNotNil(try await(_databaseService!.countDocuments(COLLECTION_NAME, filter, CountOptions().setLimit(1).setSkip(0).setMaxTimeMS(1000000000))))
        })
    }

    public func test08UpdateOne() {
        XCTAssertNoThrow({ [self] in
            let filter = ["author" : "john doe1"]
            let doc = ["author" : "john doe1", "title" : "Eve for Dummies1_1"]
            let update = ["$set" : doc]
            XCTAssertNotNil(try await(_databaseService!.updateOne(COLLECTION_NAME, filter, update, UpdateOptions().setBypassDocumentValidation(false).setUpsert(true))))
        })
    }
    
    func test09UpdateMany() {
        XCTAssertNoThrow({ [self] in
            let filter = ["author" : "john doe1"]
            let doc = ["author" : "john doe1", "title" : "Eve for Dummies1_2"]
            let update = ["$set" : doc]
            XCTAssertNotNil(try await(_databaseService!.updateMany(COLLECTION_NAME, filter, update, UpdateOptions().setBypassDocumentValidation(true))))
        })
    }
    
    func test10DeleteOne() {
        XCTAssertNoThrow({ [self] in
            let filter = ["author" : "john doe2"]
            _ = try await(_databaseService!.deleteOne(COLLECTION_NAME, filter))
        })
    }
    
    func test11DeleteMany() {
        XCTAssertNoThrow({ [self] in
            let filter = ["author" : "john doe2"]
            _ = try await(_databaseService!.deleteMany(COLLECTION_NAME, filter))
        })
    }
    
    func test12DeleteCollection() {
        XCTAssertNoThrow({ [self] in
            _ = try await(_databaseService!.deleteCollection(COLLECTION_NAME))
        })
    }
}
