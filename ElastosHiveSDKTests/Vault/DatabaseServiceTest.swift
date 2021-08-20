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
    private let COLLECTION_NAME_NOT_EXIST = "works_not_exists"
    private var _databaseService: DatabaseService?
    
    override func setUp() {
        Log.setLevel(.Debug)
        XCTAssertNoThrow(_databaseService = try TestData.shared().newVault().databaseService)
    }
    
    func test01CreateCollection() {
        XCTAssertNoThrow(try { [self] in
            XCTAssertNotNil(try await(_databaseService!.createCollection(COLLECTION_NAME)))
        }())
    }
    
    func test02CreateCollection4AlreadyExistsException() {
        do {
            _ = try await(_databaseService!.createCollection(COLLECTION_NAME))
        } catch {
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
    
    func test02InsertOne() {
        XCTAssertNoThrow(try { [self] in
            let docNode = ["author" : "john doe1", "title" : "Eve for Dummies1"]
            XCTAssertNotNil(try await(_databaseService!.insertOne(COLLECTION_NAME, docNode, InsertOptions().bypassDocumentValidation(false))))
        }())
    }
    
    func test02InsertOne4NotFoundException() {
        do {
            let docNode = ["author" : "john doe1", "title" : "Eve for Dummies1"]
            try await(_databaseService!.insertOne(COLLECTION_NAME_NOT_EXIST, docNode, InsertOptions().bypassDocumentValidation(false)))
        } catch {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    public func test03InsertMany() {
        XCTAssertNoThrow(try { [self] in
            let nodes = [
                ["author" : "john doe2", "title" : "Eve for Dummies2"],
                ["author" : "john doe3", "title" : "Eve for Dummies3"],
            ]
            XCTAssertNotNil(try await(_databaseService!.insertMany(COLLECTION_NAME, nodes, InsertOptions().bypassDocumentValidation(false).ordered(true))))
        }())
    }
    
    public func test03InsertMany4NotFoundException() {
        do {
            let nodes = [
                ["author" : "john doe2", "title" : "Eve for Dummies2"],
                ["author" : "john doe3", "title" : "Eve for Dummies3"],
            ]
            _ = try await(_databaseService!.insertMany(COLLECTION_NAME_NOT_EXIST, nodes, InsertOptions().bypassDocumentValidation(false).ordered(true)))
        } catch {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    public func test04FindOne() {
        XCTAssertNoThrow(try { [self] in
            let query = ["author" : "john doe1"]
            XCTAssertNotNil(try await(_databaseService!.findOne(COLLECTION_NAME, query, FindOptions().setSkip(0).setLimit(0))))
        }())
    }
    
    public func test04FindOne4NotFoundException() {
        do {
            let query = ["author" : "john doe1"]
            _ = try await(_databaseService!.findOne(COLLECTION_NAME_NOT_EXIST, query, FindOptions().setSkip(0).setLimit(0)))
        } catch {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    public func test05FindMany() {
        XCTAssertNoThrow(try { [self] in
            let query = ["author" : "john doe1"]
            XCTAssertTrue(try await(_databaseService!.findMany(COLLECTION_NAME, query, FindOptions().setSkip(0).setLimit(0))).count > 0)
        }())
    }
    
    public func test05FindMany4NotFoundException() {
        do {
            let query = ["author" : "john doe1"]
            try await(_databaseService!.findMany(COLLECTION_NAME_NOT_EXIST, query, FindOptions().setSkip(0).setLimit(0)))
        } catch {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    public func test06Query() {
        XCTAssertNoThrow(try { [self] in
            let query = ["author" : "john doe1"]
            XCTAssertTrue(try await(_databaseService!.query(COLLECTION_NAME, query, nil)).count > 0)
        }())
    }
    
    public func test06Query4NotFoundException() {
        do {
            let query = ["author" : "john doe1"]
            _ = try await(_databaseService!.query(COLLECTION_NAME_NOT_EXIST, query, nil))
        } catch {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    public func test06QueryWithOptions() {
        XCTAssertNoThrow(try { [self] in
            let query = ["author" : "john doe1"]
            let options = QueryOptions().setSort(AscendingSortItem("_id").getJsonValue())
            XCTAssertTrue(try await(_databaseService!.query(COLLECTION_NAME, query, options)).count > 0)
        }())
    }
    
    public func test07CountDoc() {
        XCTAssertNoThrow(try { [self] in
            let filter = ["author" : "john doe1"]
            XCTAssertTrue(try await(_databaseService!.countDocuments(COLLECTION_NAME, filter, CountOptions().setLimit(1).setSkip(0).setMaxTimeMS(1000000000))) > 0)
        }())
    }
    
    public func test07CountDoc4NotFoundException() {
        do {
            let filter = ["author" : "john doe1"]
            _ = try await(_databaseService!.countDocuments(COLLECTION_NAME_NOT_EXIST, filter, CountOptions().setLimit(1).setSkip(0).setMaxTimeMS(1000000000)))
        } catch {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    // Disabled
    public func test08UpdateOne() {
        XCTAssertNoThrow(try { [self] in
            let filter = ["author" : "john doe1"]
            let doc = ["author" : "john doe1", "title" : "Eve for Dummies1_1"]
            let update = ["$set" : doc]
            XCTAssertNotNil(try await(_databaseService!.updateOne(COLLECTION_NAME, filter, update, UpdateOptions().setBypassDocumentValidation(false).setUpsert(true))))
        }())
    }
    
    // Disabled
    func test08UpdateOne4NotFoundException() {
        let filter = ["author" : "john doe1"]
        let doc = ["author" : "john doe1", "title" : "Eve for Dummies1_1"]
        let update = ["$set" : doc]
        do {
            try await(_databaseService!.updateOne(COLLECTION_NAME_NOT_EXIST, filter, update, UpdateOptions().setBypassDocumentValidation(false).setUpsert(true)))
        } catch {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    func test09UpdateMany() {
        XCTAssertNoThrow(try { [self] in
            let filter = ["author" : "john doe1"]
            let doc = ["author" : "john doe1", "title" : "Eve for Dummies1_2"]
            let update = ["$set" : doc]
            XCTAssertNotNil(try await(_databaseService!.updateMany(COLLECTION_NAME, filter, update, UpdateOptions().setBypassDocumentValidation(true))))
        }())
    }
    
    func test09UpdateMany4NotFoundException() {
        let filter = ["author" : "john doe1"]
        let doc = ["author" : "john doe1", "title" : "Eve for Dummies1_2"]
        let update = ["$set" : doc]
        do {
            _ = try await(_databaseService!.updateMany(COLLECTION_NAME_NOT_EXIST, filter, update, UpdateOptions().setBypassDocumentValidation(true)))
        } catch {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    // Disabled
    func test10DeleteOne() {
        // TODO: deleteOne need be implemented.
        XCTAssertNoThrow(try { [self] in
            let filter = ["author" : "john doe2"]
            _ = try await(_databaseService!.deleteOne(COLLECTION_NAME, filter))
        }())
    }
    
    // Disabled
    func test10DeleteOne4NotFoundException() {
        // TODO: deleteOne need be implemented.
        let filter = ["author" : "john doe2"]
        do {
            _ = try await(_databaseService!.deleteOne(COLLECTION_NAME_NOT_EXIST, filter))
        } catch {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    func test11DeleteMany() {
        XCTAssertNoThrow(try { [self] in
            let filter = ["author" : "john doe2"]
            _ = try await(_databaseService!.deleteMany(COLLECTION_NAME, filter))
        }())
    }
    
    func test11DeleteMany4NotFoundException() {
        let filter = ["author" : "john doe2"]
        do {
            _ = try await(_databaseService!.deleteMany(COLLECTION_NAME_NOT_EXIST, filter))
        } catch {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    func test12DeleteCollection() {
        XCTAssertNoThrow(try { [self] in
            _ = try await(_databaseService!.deleteCollection(COLLECTION_NAME))
        }())
    }
}
