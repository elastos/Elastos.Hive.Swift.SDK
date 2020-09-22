
import XCTest
@testable import ElastosHiveSDK
@testable import ElastosDIDSDK

class ScriptTest: XCTestCase {
    private var client: HiveClientHandle?
    private var scripting: ScriptClient?


    func testCondition() {
        do {
            let json = "{\"name\":\"mkyong\", \"age\":37, \"c\":[\"adc\",\"zfy\",\"aaa\"], \"d\": {\"foo\": 1, \"bar\": 2}}"
            let data = json.data(using: String.Encoding.utf8)
            var dict = try JSONSerialization.jsonObject(with: data!,options: .mutableContainers) as! [String : Any]
            dict["dateField"] = Date()
            dict["idField"] = "123123123123123123"
            dict["minKeyField"] =
        } catch {
            XCTFail()
        }
    }
    /*
    @Test
    public void testCondition() throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        String json = "{\"name\":\"mkyong\", \"age\":37, \"c\":[\"adc\",\"zfy\",\"aaa\"], \"d\": {\"foo\": 1, \"bar\": 2}}";

        ObjectNode n = (ObjectNode)mapper.readTree(json);
        n.putPOJO("minKeyField", new MinKey(100));
        n.putPOJO("maxKeyField", new MaxKey(200));
        n.putPOJO("regexField", new RegularExpression("testpattern", "i"));
        n.putPOJO("tsField", new Timestamp(100000, 1234));

        Condition cond1 = new QueryHasResultsCondition("cond1", "c1", n);
        Condition cond2 = new QueryHasResultsCondition("cond2", "c2", n);
        Condition cond3 = new QueryHasResultsCondition("cond3", "c3", n);
        Condition cond4 = new QueryHasResultsCondition("cond4", "c4", n);
        RawCondition cond5 = new RawCondition(json);

        OrCondition orCond = new OrCondition("abc", new Condition[] { cond1, cond2});
        AndCondition andCond = new AndCondition("xyz", new Condition[] { cond3, cond4});

        OrCondition cond = new OrCondition("root");
        cond.append(orCond).append(cond5).append(andCond);

        JsonFactory factory = new JsonFactory();
        StringWriter jsonObjectWriter = new StringWriter();
        JsonGenerator generator = factory.createGenerator(jsonObjectWriter);



        System.out.println(cond5.serialize());
        System.out.println(cond.serialize());
    }
    */
    func testExecutable() {
        do {
            let json = "{\"name\":\"mkyong\", \"age\":37, \"c\":[\"adc\",\"zfy\",\"aaa\"], \"d\": {\"foo\": 1, \"bar\": 2}}"
            let data = json.data(using: String.Encoding.utf8)
            let dict = try JSONSerialization.jsonObject(with: data!,options: .mutableContainers) as? [String : Any]
            let exec1 = DbFindQuery("exec1", "c1", dict!)
            let exec2 = DbFindQuery("exec2", "c2", dict!)
            let exec3 = DbInsertQuery("exec3", "c3", dict!)
            let exec4 = RawExecutable(json)
            let ae = AggregatedExecutable("ae")
            try ae.append(exec1)
                .append(exec2)
                .append(exec3)
            print(ae)
            let ae2 = AggregatedExecutable("ae2")
            try ae2.append(exec1).append(exec2).append(ae).append(exec3)
            print(ae2)
        } catch {
            XCTFail()
        }
    }

    func testRegisterScriptNoCondition() {
        let json = "{\"type\":\"find\",\"name\":\"get_groups\",\"body\":{\"collection\":\"test_group\",\"filter\":{\"*caller_did\":\"friends\"}}}"
        let lock = XCTestExpectation(description: "wait for test.")
        scripting!.registerScript("script_no_condition", RawExecutable(json)).done { re in
            XCTAssertTrue(re)
            lock.fulfill()
        }.catch { error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    // TODO:
    func testRegisterScriptWithCondition() {
        let json = "{\"type\":\"find\",\"name\":\"get_groups\",\"body\":{\"collection\":\"test_group\",\"filter\":{\"*caller_did\":\"friends\"}}}"
        let lock = XCTestExpectation(description: "wait for test.")
        scripting!.registerScript("script_no_condition", RawExecutable(json)).done { re in
            XCTAssertTrue(re)
            lock.fulfill()
        }.catch { error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testCallScriptNoParams() {
        let lock = XCTestExpectation(description: "wait for test.")
        scripting?.call("script_no_condition").done{ re in
            lock.fulfill()
        }.catch{ err in
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }

    func testCallScriptWithParams() {
        do {
            let lock = XCTestExpectation(description: "wait for test.")
            let param = "{\"group_id\":{\"$oid\":\"5f497bb83bd36ab235d82e6a\"}}"
            let para = try JSONSerialization.jsonObject(with: param.data(using: .utf8)!, options: [ ]) as! [String : Any]
            scripting?.call("script_no_condition", para).done{ output in
                let data: Data = output.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey)! as! Data
                let rejson = try JSONSerialization.jsonObject(with: data , options: .mutableContainers) as AnyObject
                print(rejson)
                XCTAssertTrue(true)
                lock.fulfill()
            }.catch{ err in
                XCTAssertTrue(true)
                lock.fulfill()
            }
            self.wait(for: [lock], timeout: 10000.0)
        } catch {
            XCTFail()
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        do {
            let json = DOC_STR
            let doc = try DIDDocument.convertToDIDDocument(fromJson: json)
            let options = HiveClientOptions()
            _ = options.setAuthenticator(VaultAuthenticator())
            _ = options.setAuthenticationDIDDocument(doc)
            _ = options.setDidResolverUrl("http://api.elastos.io:21606")
            _ = options.setLocalDataPath(localDataPath)

            HiveClientHandle.setVaultProvider(OWNERDID, PROVIDER)
            client = try HiveClientHandle.createInstance(withOptions: options)
            let lock = XCTestExpectation(description: "wait for test.")
            _ = self.client?.getVault(OWNERDID).get{ result in
                self.scripting = (result.scripting as! ScriptClient)
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
