
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

            collation = Collation()
            collation = collation.locale("en_us")
                .alternate(Alternate.SHIFTED)
                .normalization(true)
                .numericOrdering(false)
                .strength(Strength.PRIMARY)
            var cco = CreateCollectionOptions()
            _ = cco.capped(true)
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
            _ = cco.capped(true)
                .collation(collation)
                .readPreference(ReadPreference.PRIMARY_PREFERRED)
                .writeConcern(wc)
            json = try cco.serialize()
            cco = try CreateCollectionOptions.deserialize(json)
            json2 = try cco.serialize()

            var dopt = DeleteOptions()
            _ = dopt.collation(collation)
            json = try dopt.serialize()
            dopt = try DeleteOptions.deserialize(json)
            json2 = try dopt.serialize()

            var fo = FindOptions()
            let projection = "{\"name\":\"mkyong\", \"age\":37, \"c\":[\"adc\",\"zfy\",\"aaa\"], \"d\": {\"foo\": 1, \"bar\": 2}}"
            let data = projection.data(using: String.Encoding.utf8)
            let paramars = try JSONSerialization.jsonObject(with: data!,
                                                            options: .mutableContainers) as? [String : Any] ?? [: ]
            _ = fo.allowDiskUse(true)
                .batchSize(100)
                .collation(collation)
                .hint([VaultIndex("didurl", VaultIndex.Order.ASCENDING), VaultIndex("type", VaultIndex.Order.DESCENDING)])
                .projection(paramars)
                .max(10)
            json = try fo.serialize()
            fo = try FindOptions.deserialize(json)
            json2 = try fo.serialize()

            var io = InsertOptions()
            _ = io.bypassDocumentValidation(true)
            json = try io.serialize()
            io = try InsertOptions.deserialize(json)
            json2 = try io.serialize()

            var uo = UpdateOptions()
            _ = uo.bypassDocumentValidation(value: true)
                .collation(value: collation)
                .upsert(value: true)
            json = try uo.serialize()
            uo = try UpdateOptions.deserialize(json)
            json2 = try uo.serialize()
        } catch {
            print(error)
            XCTFail()
        }
    }

    func test02_DbResults() {
        do {
            let json = "{\"deleted_count\":1000}"
            var ds = DeleteResult.deserialize(json)

        } catch {
            print(error)
            XCTFail()
        }
    }

    /*
     @Test
     public void test02_DbResults() throws Exception {
         String json = "{\"deleted_count\":1000}";
         DeleteResult ds = DeleteResult.deserialize(json);
         assertEquals(1000, ds.deletedCount());
         json = ds.serialize();
         ds = DeleteResult.deserialize(json);
         assertEquals(1000, ds.deletedCount());

         json = "{\"acknowledged\":true,\"inserted_id\":\"test_inserted_id\"}";
         InsertOneResult ior = InsertOneResult.deserialize(json);
         assertTrue(ior.acknowledged());
         assertEquals("test_inserted_id", ior.insertedId());
         json = ior.serialize();
         ior = InsertOneResult.deserialize(json);
         assertTrue(ior.acknowledged());
         assertEquals("test_inserted_id", ior.insertedId());

         json = "{\"acknowledged\":false,\"inserted_ids\":[\"test_inserted_id1\",\"test_inserted_id2\"]}";
         InsertManyResult imr = InsertManyResult.deserialize(json);
         assertFalse(imr.acknowledged());
         List<String> ids = imr.insertedIds();
         assertNotNull(ids);
         assertEquals(2, ids.size());
         json = imr.serialize();
         imr = InsertManyResult.deserialize(json);
         assertFalse(imr.acknowledged());
         ids = imr.insertedIds();
         assertNotNull(ids);
         assertEquals(2, ids.size());

         json = "{\"matched_count\":10,\"modified_count\":5,\"upserted_count\":3,\"upserted_id\":\"test_id\"}";
         UpdateResult ur = UpdateResult.deserialize(json);
         assertEquals(10, ur.matchedCount());
         assertEquals(5, ur.modifiedCount());
         assertEquals(3, ur.upsertedCount());
         assertEquals("test_id", ur.upsertedId());
         json = ur.serialize();
         ur = UpdateResult.deserialize(json);
         assertEquals(10, ur.matchedCount());
         assertEquals(5, ur.modifiedCount());
         assertEquals(3, ur.upsertedCount());
         assertEquals("test_id", ur.upsertedId());
     }
     */
    func testDeleteCollection() {
        let lock = XCTestExpectation(description: "wait for test.")
        database?.deleteCollection("new").done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testInsertOne() {
        let lock = XCTestExpectation(description: "wait for test.")
        let inserInfo = ["author": "john doe1", "title": "Eve for Dummies1"]
        database?.insertOne("new", inserInfo, options: nil).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testInsertMany() {
        let lock = XCTestExpectation(description: "wait for test.")
        let inserInfo1 = ["author": "john doe1", "title": "Eve for Dummies1"]
        let inserInfo2 = ["author": "john doe2", "title": "Eve for Dummies2"]
        let insertOptions = InsertOptions()
        database?.insertMany("new", [inserInfo1, inserInfo2], options: insertOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testCountDocuments() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filter = ["author": "john doe2"]
        let options = CountOptions()
//        options.limit(1).skip(0).maxTimeMS(1000000000); //TODO:
        database?.countDocuments("new", filter, options: options).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testFindOne() {
        let lock = XCTestExpectation(description: "wait for test.")
        let queryInfo = ["author": "john doe1"]

        let findOptions = FindOptions()
        database?.findOne("new", queryInfo, options: findOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testFindMany() {
        let lock = XCTestExpectation(description: "wait for test.")
        let queryInfo = ["author": "john doe1"]

        let findOptions = FindOptions()
        database?.findMany("new", queryInfo, options: findOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testUpdateOne() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["author": "john doe1"]
        let update = ["author": "john doe2_1", "title": "Eve for Dummies2_1_1"]
        let updateOptions = UpdateOptions()
        database?.updateOne("new", filterInfo, update, options: updateOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testUpdateMany() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["author": "john doe1"]
        let update = ["author": "john doe2_1", "title": "Eve for Dummies2_1_1_2"]
        let updateOptions = UpdateOptions()
        database?.updateMany("new", filterInfo, update, options: updateOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testUpdateManyWith$param() {
        let dic = ["_error": ["message": "Exception: method: 'query_update_one', Err: The dollar ($) prefixed field '$set' in '$set' is not valid for storage., full error: {'index': 0, 'code': 52, 'errmsg': \"The dollar ($) prefixed field '$set' in '$set' is not valid for storage.\"}", "code": 500]]
        let data = try? JSONSerialization.data(withJSONObject: dic as Any, options: [])
        let dicStr = String(data: data!, encoding: String.Encoding.utf8)!
        print(dicStr)

        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["myParam": "hey"]
        let update = ["myParam": "hey", "randomParam": "0.7522371070254117"]
        let updateOptions = UpdateOptions()
        database?.updateMany("new0", filterInfo, update, options: updateOptions).done{ result in
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

    func testDeleteOne() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["author": "john doe2"]
        let deleteOptions = DeleteOptions()
        database?.deleteOne("new", filterInfo, options: deleteOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testDeleteMany() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["author": "john doe2"]
        let deleteOptions = DeleteOptions()
        database?.deleteMany("new", filterInfo, options: deleteOptions).done{ result in
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
            user = try UserFactory.createUser1()
            let lock = XCTestExpectation(description: "wait for test.")
            user!.client.getVault(OWNERDID).done { [self] vault in
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
