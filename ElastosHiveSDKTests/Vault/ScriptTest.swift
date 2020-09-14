
import XCTest
@testable import ElastosHiveSDK
@testable import ElastosDIDSDK

class ScriptTest: XCTestCase {
    private var client: HiveClientHandle?
    private var scripting: ScriptClient?


    func testExecutable() {
        do {
            let json = "{\"name\":\"mkyong\", \"age\":37, \"c\":[\"adc\",\"zfy\",\"aaa\"], \"d\": {\"foo\": 1, \"bar\": 2}}"
            let data = json.data(using: String.Encoding.utf8)
            let dict = try JSONSerialization.jsonObject(with: data!,options: .mutableContainers) as? [String : Any]
            print(dict)
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
        do {
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
        } catch {
            XCTFail()
        }
    }
//    func testExecutable() {
//        do {
//
//        } catch {
//            XCTFail()
//        }
//    }
    /*
     @Test
     public void registerScriptNoCondition() {
         try {
             String json = "{\"type\":\"find\",\"name\":\"get_groups\",\"body\":{\"collection\":\"test_group\",\"filter\":{\"*caller_did\":\"friends\"}}}";
             scripting.registerScript("script_no_condition", new RawExecutable(json)).get();
         } catch (Exception e) {
             e.printStackTrace();
         }
     }

     */
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
