
import XCTest
@testable import ElastosHiveSDK
@testable import ElastosDIDSDK

class ScriptTest: XCTestCase {
    private var client: HiveClientHandle?
    private var scripting: ScriptClient?


    func testExecutable() {
        do {
            let json = "{\"name\":\"mkyong\", \"age\":37, \"c\":[\"adc\",\"zfy\",\"aaa\"], \"d\": {\"foo\": 1, \"bar\": 2}}"
            
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
     public void testExecutable() throws Exception {
         ObjectMapper mapper = new ObjectMapper();
         String json = "{\"name\":\"mkyong\", \"age\":37, \"c\":[\"adc\",\"zfy\",\"aaa\"], \"d\": {\"foo\": 1, \"bar\": 2}}";

         JsonNode n = mapper.readTree(json);

         Executable exec1 = new DbFindQuery("exec1", "c1", n);
         Executable exec2 = new DbFindQuery("exec2", "c2", n);
         Executable exec3 = new DbInsertQuery("exec3", "c3", n);
         Executable exec4 = new RawExecutable(json);

         AggregatedExecutable ae = new AggregatedExecutable("ae");
         ae.append(exec1).append(exec2).append(exec3);

         System.out.println(ae.serialize());

         AggregatedExecutable ae2 = new AggregatedExecutable("ae2");
         ae2.append(exec1).append(exec2).append(ae).append(exec3);

         System.out.println(ae2.serialize());
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
                self.scripting = (result.database as! ScriptClient)
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
