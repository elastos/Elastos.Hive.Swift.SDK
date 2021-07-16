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
    private var databaseService: DatabaseService?
    
    override func setUp() {
        XCTAssertNoThrow(databaseService = TestData.shared().newVault().databaseService)
    }
    

    func test1CreateCollection() {
        let lock = XCTestExpectation(description: "wait for create collection.")
        do {
            _ = try await(databaseService!.createCollection(COLLECTION_NAME))
            lock.fulfill()
        } catch {
            print(error)
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test2InsertOne() {
        let lock = XCTestExpectation(description: "wait for test.")
        let docNode = ["author": "john doe1", "title": "Eve for Dummies1"]
        databaseService?.insertOne(COLLECTION_NAME, docNode,InsertOptions().bypassDocumentValidation(false)).done{ result in
            print(result)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
}
/*
class DatabaseServiceTest: XCTestCase {
    private var database: DatabaseProtocol?
    private static let COLLECTION_NAME: String = "works"
    
    func test01CreateCollection() {
        let lock = XCTestExpectation(description: "wait for create collection.")
        self.database!.createCollection(DatabaseServiceTest.COLLECTION_NAME, nil).done { isSuccess in
            XCTAssert(isSuccess)
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test02InsertOne() {
        let lock = XCTestExpectation(description: "wait for insert one.")
        let docNode = ["author": "john doe1", "title": "Eve for Dummies1"]
        let insertOptions = InsertOneOptions(false)
        self.database!.insertOne(DatabaseServiceTest.COLLECTION_NAME, docNode, insertOptions).done{ result in
            XCTAssertTrue(result.insertedId.count > 0, "insert one test case passed")
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test03InsertMany() {
        let lock = XCTestExpectation(description: "wait for test insert many.")
        let docNode1 = ["author": "john doe2", "title": "Eve for Dummies2"]
        let docNode2 = ["author": "john doe3", "title": "Eve for Dummies3"]
        let insertOptions = InsertManyOptions(false, true)
        self.database!.insertMany(DatabaseServiceTest.COLLECTION_NAME, [docNode1, docNode2], insertOptions).done{ result in
            XCTAssertTrue(result.insertedIds.count > 0, "insert many test case passed")
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test04FindOne() {
        let lock = XCTestExpectation(description: "wait for find one.")
        let queryInfo = ["author": "john doe1"]
        let findOptions = FindOptions()
        findOptions.skip = 0
        findOptions.sort = [["_id": -1]]
        findOptions.allowPartialResults = false
        findOptions.returnKey = false
        findOptions.batchSize = 0
        findOptions.projection = ["_id": false]
        
        self.database!.findOne(DatabaseServiceTest.COLLECTION_NAME, queryInfo, findOptions).done{ result in
            XCTAssertTrue(true, "find one test cast passed")
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test05FindMany() {
        let lock = XCTestExpectation(description: "wait for find many.")
        let queryInfo = ["author": "john doe1"]
        let findOptions = FindOptions()
        findOptions.skip = 0
        findOptions.sort = [["_id": -1]]
        findOptions.allowPartialResults = false
        findOptions.returnKey = false
        findOptions.batchSize = 0
        findOptions.projection = ["_id": false]
        
        self.database!.findMany(DatabaseServiceTest.COLLECTION_NAME, queryInfo, findOptions).done{ result in
            XCTAssertTrue(result.items.count > 0, "find many test case passed")
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test06CountDoc() {
        let lock = XCTestExpectation(description: "wait for test count doc.")
        let filter = ["author": "john doe2"]
        let countOptions = CountOptions()
        countOptions.limit = 1
        countOptions.skip = 0
        countOptions.maxTimeMS = 1000000000
        
        self.database!.countDocuments(DatabaseServiceTest.COLLECTION_NAME, filter, countOptions).done{ result in
            XCTAssertTrue(result > 0, "count doc test case passed")
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    override func setUpWithError() throws {
        let lock = XCTestExpectation(description: "wait for test.")
        Log.setLevel(.Debug)
        self.database = try TestData.shared.newVault().databaseService
        lock.fulfill()
        self.wait(for: [lock], timeout: 100.0)
    }
}
*/
