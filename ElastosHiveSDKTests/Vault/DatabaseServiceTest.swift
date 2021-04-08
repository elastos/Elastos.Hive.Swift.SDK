import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class DatabaseServiceTest: XCTestCase {
    private var database: DatabaseServiceRender?
    private static let COLLECTION_NAME: String = "works"
    
    func testCreateCollection() {
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
    
    func testInsertOne() {
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
    
    func testInsertMany() {
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

    func testFindOne() {
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
    
    func testFindMany() {
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
    
    func testCountDoc() {
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
    
//    func testUpdateOne() {
//        let lock = XCTestExpectation(description: "wait for update one.")
//        let filterInfo = ["author": "john doe1"]
//        let update = ["$set": ["author": "john doe2_1", "title": "Eve for Dummies2"]]
//        let updateOptions = UpdateOptions()
//        _ = updateOptions.upsert(value: true).bypassDocumentValidation(value: false)
//        self.database!.updateOne(collectionName, filterInfo, update, updateOptions).done{ result in
//            XCTAssertTrue(true)
//            lock.fulfill()
//        }.catch { [self] error in
//            testCaseFailAndThrowError(error, lock)
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//    
//    func testUpdateMany() {
//        let lock = XCTestExpectation(description: "wait for update many.")
//        let filterInfo = ["author": "john doe1"]
//        let update = ["$set":["author": "john doe1", "title": "Eve for Dummies2"]]
//        let updateOptions = UpdateOptions()
//        _ = updateOptions.upsert(value: true).bypassDocumentValidation(value: false)
//        self.database!.updateMany(collectionName, filterInfo, update, updateOptions).done{ result in
//            XCTAssertTrue(true)
//            lock.fulfill()
//        }.catch { [self] error in
//            testCaseFailAndThrowError(error, lock)
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//
//    func testDeleteOne() {
//        let lock = XCTestExpectation(description: "wait for delete one.")
//        let filterInfo = ["author": "john doe2"]
//        let deleteOptions = DeleteOptions()
//        self.database!.deleteOne(collectionName, filterInfo, options: deleteOptions).done{ result in
//            XCTAssertTrue(true)
//            lock.fulfill()
//        }.catch { [self] error in
//            testCaseFailAndThrowError(error, lock)
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//    
//    func testDeleteMany() {
//        let lock = XCTestExpectation(description: "wait for test delete many.")
//        let filterInfo = ["author": "john doe2"]
//        let deleteOptions = DeleteOptions()
//        self.database!.deleteMany(collectionName, filterInfo, options: deleteOptions).done{ result in
//            XCTAssertTrue(true)
//            lock.fulfill()
//        }.catch { [self] error in
//            testCaseFailAndThrowError(error, lock)
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//    
//    func testDeleteCollection() {
//        let lock = XCTestExpectation(description: "wait for test delete collection.")
//        self.database!.deleteCollection(collectionName).done{ result in
//            XCTAssertTrue(true)
//            lock.fulfill()
//        }.catch { [self] error in
//            testCaseFailAndThrowError(error, lock)
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
    
    override func setUpWithError() throws {
        let lock = XCTestExpectation(description: "wait for test.")
        Log.setLevel(.Debug)
        self.database = (TestData.shared.newVault().databaseService as! DatabaseServiceRender)
        lock.fulfill()
        self.wait(for: [lock], timeout: 100.0)
    }
}
