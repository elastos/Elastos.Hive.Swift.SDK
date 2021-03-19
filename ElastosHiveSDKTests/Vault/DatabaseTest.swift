
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class DatabaseTest: XCTestCase {
    private var client: HiveClientHandle?
    private var database: Database?
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
   
    func test03_DbDataTypes() {
        var values: [String: Any] = [: ]
        values["testDate"] = Date()
        values["testMaxKey"] = MaxKey(10000)
        values["testMinKey"] = MinKey(10)
        values["testObjectId"] = ObjectId("iiiiiiiidddddddd")
        values["testTimestamp"] = Timestamp(123456, 789)
        values["testRegex"] = RegularExpression("*FooBar", "all")
        let data = try? JSONSerialization.data(withJSONObject: values as Any, options: [])
        let json = String(data: data!, encoding: String.Encoding.utf8)!
        
// TODO:
//        json = mapper.writeValueAsString(tdt);
//        TestDBDataTypes tdt2 = mapper.readValue(json, TestDBDataTypes.class);
//        String json2 = mapper.writeValueAsString(tdt2);
//        assertEquals(json, json2);
    }
    
    func test04_createCollection() {
        let lock = XCTestExpectation(description: "wait for test.")
        let docNode = ["author": "john doe1", "title": "Eve for Dummies1"]
        let insertOptions = InsertOptions()
        _ = insertOptions.bypassDocumentValidation(false).ordered(true)
        database?.createCollection(collectionName, options: nil).then{ [self] _ -> Promise<InsertOneResult> in
            return self.database!.insertOne(collectionName, docNode, options: insertOptions)
        }.done{ result in
                print(result)
            lock.fulfill()
        }.catch{ e in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        do {
            Log.setLevel(.Debug)
            TestData.shared()
            self.wait(for: [lock], timeout: 100.0)
        } catch {
            XCTFail()
        }
    }
    /*
     @BeforeClass
     public static void setUp() {
         try {
             database = TestData.getInstance().newVault().getDatabaseService();
         } catch (HiveException | DIDException e) {
             e.printStackTrace();
         }
     }
     */
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /*
     @Test
     public void test04_createCollection() {
         CompletableFuture<Boolean> future = database.createCollection(collectionName, null)
                 .handle((success, ex) -> (ex == null));

         try {
             assertTrue(future.get());
             assertTrue(future.isCompletedExceptionally() == false);
             assertTrue(future.isDone());
         } catch (Exception e) {
             e.printStackTrace();
             fail();
         }
     }
     */


}
