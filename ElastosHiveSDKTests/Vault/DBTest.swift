
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class VaultAuthenticator: Authenticator {
    func requestAuthentication(_ jwtToken: String) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            do{
                let authtoken = try user?.presentationInJWT!.getAuthToken(jwtToken)
                print("authtoken = \(authtoken)")
                resolver.fulfill(authtoken!)
            }
            catch {
                resolver.reject(error)
            }
        }
    }
}

public var user: UserFactory?
class DBTest: XCTestCase {
    private var client: HiveClientHandle?
    private var database: DatabaseClient?
    private let collectionName = "works"

    func test01_DbOptions() {
        do {
            var collation = Collation()
            collation = collation.locale("en_us")
                .alternate(Alternate.SHIFTED)
                .backwards(true)
                .caseFirst(CaseFirst.OFF)
                .caseLevel(true)
                .maxVariable(MaxVariable.PUNCT)
                .normalization(true)
                .numericOrdering(false)
                .strength(Strength.PRIMARY)

            var co = CountOptions()
            co = try co.collation(collation)
                .hint(VaultIndex("idx_01", VaultIndex.Order.ASCENDING))
                .limit(100)
                .maxTimeMS(1000)
                .skip(50)
            var json = try co.serialize()
            co = try CountOptions.deserialize(json)
            var json2 = try co.serialize()

            co = CountOptions()
            _ = co.hint([VaultIndex("idx_01", VaultIndex.Order.ASCENDING), VaultIndex("idx_02", VaultIndex.Order.DESCENDING)])
                .limit(100)
            json = try co.serialize()
            co = try CountOptions.deserialize(json)
            json2 = try co.serialize()
            XCTAssertEqual(json.count, json2.count)
            
            collation = Collation()
            collation = collation.locale("en_us")
                .alternate(Alternate.SHIFTED)
                .normalization(true)
                .numericOrdering(false)
                .strength(Strength.PRIMARY)
            var cco = CreateCollectionOptions()
            _ = try cco.capped(true)
                .collation(collation)
                .max(10)
                .readConcern(ReadConcern.AVAILABLE)
                .readPreference(ReadPreference.PRIMARY_PREFERRED)
                .writeConcern(WriteConcern(10, 100, true, false))
                .size(123456)

            let wc = WriteConcern()
            _ = wc.fsync(true)
                .w(10)
            cco = CreateCollectionOptions()
            _ = try cco.capped(true)
                .collation(collation)
                .readPreference(ReadPreference.PRIMARY_PREFERRED)
                .writeConcern(wc)
            json = try cco.serialize()
            cco = try CreateCollectionOptions.deserialize(json)
            json2 = try cco.serialize()
            XCTAssertEqual(json.count, json2.count)
            
            var dopt = DeleteOptions()
            _ = try dopt.collation(collation)
            json = try dopt.serialize()
            dopt = try DeleteOptions.deserialize(json)
            json2 = try dopt.serialize()
            XCTAssertEqual(json.count, json2.count)
            
            var fo = FindOptions()
            let projection = "{\"name\":\"mkyong\", \"age\":37, \"c\":[\"adc\",\"zfy\",\"aaa\"], \"d\": {\"foo\": 1, \"bar\": 2}}"
            let data = projection.data(using: String.Encoding.utf8)
            let paramars = try JSONSerialization.jsonObject(with: data!,
                                                            options: .mutableContainers) as? [String : Any] ?? [: ]
            _ = try fo.allowDiskUse(true)
                .batchSize(100)
                .collation(collation)
                .hint([VaultIndex("didurl", VaultIndex.Order.ASCENDING), VaultIndex("type", VaultIndex.Order.DESCENDING)])
                .projection(paramars)
                .max(10)
            json = try fo.serialize()
            fo = try FindOptions.deserialize(json)
            json2 = try fo.serialize()
            XCTAssertEqual(json.count, json2.count)
            
            var io = InsertOptions()
            _ = io.bypassDocumentValidation(true)
            json = try io.serialize()
            io = try InsertOptions.deserialize(json)
            json2 = try io.serialize()
            XCTAssertEqual(json.count, json2.count)
            
            var uo = UpdateOptions()
            _ = try uo.bypassDocumentValidation(value: true)
                .collation(value: collation)
                .upsert(value: true)
            json = try uo.serialize()
            uo = try UpdateOptions.deserialize(json)
            json2 = try uo.serialize()
            XCTAssertEqual(json.count, json2.count)
        } catch {
            print(error)
            XCTFail()
        }
    }

    func test02_DbResults() {
        do {
            var json = "{\"deleted_count\":1000}"
            var ds = try DeleteResult.deserialize(json)
            XCTAssertEqual(1000, ds.deletedCount)
            json = try ds.serialize()
            ds = try DeleteResult.deserialize(json)
            XCTAssertEqual(1000, ds.deletedCount)
            json = "{\"acknowledged\":true,\"inserted_id\":\"test_inserted_id\"}"
            var ior = try InsertOneResult.deserialize(json)
            XCTAssertTrue(ior.acknowledged!)
            XCTAssertEqual("test_inserted_id", ior.insertedId())
            json = try ior.serialize()
            ior = try InsertOneResult.deserialize(json)
            XCTAssertTrue(ior.acknowledged!)
            XCTAssertEqual("test_inserted_id", ior.insertedId())

            json = "{\"acknowledged\":false,\"inserted_ids\":[\"test_inserted_id1\",\"test_inserted_id2\"]}"
            var imr = try InsertManyResult.deserialize(json)
            XCTAssertFalse(imr.acknowledged!)
            var ids = imr.insertedIds()
            XCTAssertNotNil(ids)
            XCTAssertEqual(2, ids.count)
            json = try imr.serialize()
            imr = try InsertManyResult.deserialize(json)
            XCTAssertFalse(imr.acknowledged!)
            ids = imr.insertedIds()
            XCTAssertNotNil(ids)
            XCTAssertEqual(2, ids.count)

            json = "{\"matched_count\":10,\"modified_count\":5,\"upserted_count\":3,\"upserted_id\":\"test_id\"}"
            var ur = try UpdateResult.deserialize(json)
            XCTAssertEqual(10, ur.matchedCount())
            XCTAssertEqual(5, ur.modifiedCount())
            XCTAssertEqual(3, ur.upsertedCount())
            XCTAssertEqual("test_id", ur.upsertedId())
            json = try ur.serialize()
            ur = try UpdateResult.deserialize(json)
            XCTAssertEqual(10, ur.matchedCount())
            XCTAssertEqual(5, ur.modifiedCount())
            XCTAssertEqual(3, ur.upsertedCount())
            XCTAssertEqual("test_id", ur.upsertedId())
        } catch {
            print(error)
            XCTFail()
        }
    }

    func test04_CreateCol() {
        let lock = XCTestExpectation(description: "wait for test.")
        database?.createCollection(collectionName).done{ success in
            XCTAssertTrue(success)
            lock.fulfill()
        }.catch{ e in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test05_InsertOne() {
        let lock = XCTestExpectation(description: "wait for test.")
        let docNode = ["author": "john doe1", "title": "Eve for Dummies1"]
        let insertOptions = InsertOptions()
        _ = insertOptions.bypassDocumentValidation(false).ordered(true)
        database?.insertOne(collectionName, docNode, options: insertOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test06_InsertMany() {
        let lock = XCTestExpectation(description: "wait for test.")
        let docNode1 = ["author": "john doe2", "title": "Eve for Dummies2"]
        let docNode2 = ["author": "john doe3", "title": "Eve for Dummies3"]
        let insertOptions = InsertOptions()
        _ = insertOptions.bypassDocumentValidation(false).ordered(true)
        database?.insertMany(collectionName, [docNode1, docNode2], options: insertOptions).done{ result in
            XCTAssertTrue(result.insertedIds().count > 0)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test07_FindOne() {
        let lock = XCTestExpectation(description: "wait for test.")
        let queryInfo = ["author": "john doe1"]

        let findOptions = FindOptions()
        _ = findOptions.skip(0)
            .allowPartialResults(false)
            .returnKey(false)
            .batchSize(0)
            .projection(["_id": false])
        database?.findOne(collectionName, queryInfo, options: findOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test08_FindMany() {
        let lock = XCTestExpectation(description: "wait for test.")
        let queryInfo = ["author": "john doe1"]

        let findOptions = FindOptions()
        _ = findOptions.skip(0)
            .allowPartialResults(false)
            .returnKey(false)
            .batchSize(0)
            .projection(["_id": false])
        database?.findMany(collectionName, queryInfo, options: findOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test09_countDoc() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filter = ["author": "john doe2"]
        let options = CountOptions()
        _ = options.limit(1).skip(0).maxTimeMS(1000000000)
        database?.countDocuments(collectionName, filter, options: options).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test10_UpdateOne() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["author": "john doe1"]
        let update = ["$set": ["author": "john doe2_1", "title": "Eve for Dummies2"]]
        let updateOptions = UpdateOptions()
        _ = updateOptions.upsert(value: true).bypassDocumentValidation(value: false)
        database?.updateOne(collectionName, filterInfo, update, options: updateOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test11_UpdateMany() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["author": "john doe1"]
        let update = ["$set":["author": "john doe2_1", "title": "Eve for Dummies2_1_1_2"]]
        let updateOptions = UpdateOptions()
        updateOptions.upsert(value: true).bypassDocumentValidation(value: false)
        database?.updateMany(collectionName, filterInfo, update, options: updateOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test12_UpdateManyWith$param() {
        let dic = ["_error": ["message": "Exception: method: 'query_update_one', Err: The dollar ($) prefixed field '$set' in '$set' is not valid for storage., full error: {'index': 0, 'code': 52, 'errmsg': \"The dollar ($) prefixed field '$set' in '$set' is not valid for storage.\"}", "code": 500]]
        let data = try? JSONSerialization.data(withJSONObject: dic as Any, options: [])
        let dicStr = String(data: data!, encoding: String.Encoding.utf8)!
        print(dicStr)

        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["myParam": "hey"]
        let update = ["$set": ["myParam": "hey", "randomParam": "0.7522371070254117"]]
        let updateOptions = UpdateOptions()
        database?.updateMany(collectionName, filterInfo, update, options: updateOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            let e = HiveError.description(error as! HiveError)
            print(e)
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test13_DeleteOne() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["author": "john doe2"]
        let deleteOptions = DeleteOptions()
        database?.deleteOne(collectionName, filterInfo, options: deleteOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test14_DeleteMany() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["author": "john doe2"]
        let deleteOptions = DeleteOptions()
        database?.deleteMany(collectionName, filterInfo, options: deleteOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test15_deleteCol() {
        let lock = XCTestExpectation(description: "wait for test.")
        database?.deleteCollection(collectionName).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        do {
            Log.setLevel(.Debug)
            user = try UserFactory.createUser1()
            let lock = XCTestExpectation(description: "wait for test.")
            user!.client.getVault(user!.ownerDid, user?.provider).done { [self] vault in
                self.database = (vault.database as! DatabaseClient)
                lock.fulfill()
            }.catch { error in
                print(error)
                lock.fulfill()
            }
            self.wait(for: [lock], timeout: 100.0)
        } catch {
            XCTFail()
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
