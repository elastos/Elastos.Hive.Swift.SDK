
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class ScriptTest: XCTestCase {
    private var client: HiveClientHandle?
    private var scripting: ScriptClient?
    private var noConditionName: String = "get_groups"
    private var withConditionName: String = "get_group_messages"

    func test1_Condition() {
        do {
            let json = "{\"name\":\"mkyong\", \"age\":37, \"c\":[\"adc\",\"zfy\",\"aaa\"], \"d\": {\"foo\": 1, \"bar\": 2}}"
            let data = json.data(using: String.Encoding.utf8)
            var dict = try JSONSerialization.jsonObject(with: data!,options: .mutableContainers) as! [String : Any]
            dict["dateField"] = Date()
            dict["idField"] = ObjectId("123123123123123123")
            dict["minKeyField"] = MinKey(100)
            dict["maxKeyField"] = MaxKey(200)
            dict["regexField"] = RegularExpression("testpattern", "i")
            dict["tsField"] = Timestamp(100000, 1234)

            let cond1 = QueryHasResultsCondition("cond1", "c1", dict)
            let cond2 = QueryHasResultsCondition("cond2", "c2", dict)
            let cond3 = QueryHasResultsCondition("cond3", "c3", dict)
            let cond4 = QueryHasResultsCondition("cond4", "c4", dict)
            let cond5 = RawCondition(json)

            let orCond = OrCondition("abc", [cond1, cond2])
            let andCond = AndCondition("xyz", [cond3, cond4])
            let cond = OrCondition("root")
            cond.append(orCond).append(cond5).append(andCond)

//            print(cond5.serialize())
            print(try cond.serialize())
            print(try cond.serialize())
        } catch {
            XCTFail()
        }
    }

    func test2_Executable() {
        do {
            let json = "{\"name\":\"mkyong\", \"age\":37, \"c\":[\"adc\",\"zfy\",\"aaa\"], \"d\": {\"foo\": 1, \"bar\": 2}}"
            let data = json.data(using: String.Encoding.utf8)
            let dict = try JSONSerialization.jsonObject(with: data!,options: .mutableContainers) as? [String : Any]
            let exec1 = DbFindQuery("exec1", "c1", dict!)
            let exec2 = DbFindQuery("exec2", "c2", dict!)
            let exec3 = DbInsertQuery("exec3", "c3", dict!)
            let exec4 = RawExecutable(executable: json)
            let ae = AggregatedExecutable("ae")
            try ae.append(exec1)
                  .append(exec2)
                  .append(exec3)
            print(ae)
//            print(try ae.serialize())
            //System.out.println(ae.serialize());
            let ae2 = AggregatedExecutable("ae2")
            try ae2.append(exec1).append(exec2).append(ae).append(exec3)
            print(ae2)
            print(try ae2.serialize())
            print(try ae2.serialize())
            // System.out.println(ae2.serialize())
        } catch {
            XCTFail()
        }
    }

    func test03_registerNoCondition() {
        do {
            let datafilter = "{\"friends\":\"$caller_did\"}".data(using: String.Encoding.utf8)
            let filter = try JSONSerialization.jsonObject(with: datafilter!,options: .mutableContainers) as? [String : Any]
            let dataoptions = "{\"projection\":{\"_id\":false,\"name\":true}}".data(using: String.Encoding.utf8)
            let options = try JSONSerialization.jsonObject(with: dataoptions!,options: .mutableContainers) as? [String : Any]

            let executable: DbFindQuery = DbFindQuery("get_groups", "groups", filter!, options!)
            let lock = XCTestExpectation(description: "wait for test.")
            scripting!.registerScript(noConditionName, executable).done { re in
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

    func test04_registerWithCondition() {
        do {
            let datafilter = "{\"_id\":\"$params.group_id\",\"friends\":\"$caller_did\"}".data(using: String.Encoding.utf8)
            let filter = try JSONSerialization.jsonObject(with: datafilter!,options: .mutableContainers) as? [String : Any]
            let executable: DbFindQuery = DbFindQuery("get_groups", "test_group", filter!)
            let condition: QueryHasResultsCondition = QueryHasResultsCondition("verify_user_permission", "test_group", filter!)
            let lock = XCTestExpectation(description: "wait for test.")
            scripting!.registerScript(withConditionName, condition, executable).done { re in
                XCTAssertTrue(re)
                lock.fulfill()
            }.catch { error in
                XCTFail()
                lock.fulfill()
            }
            self.wait(for: [lock], timeout: 1000.0)
        } catch {

        }
    }

    func test05_callStringType() {
        let lock = XCTestExpectation(description: "wait for test.")
        scripting?.call(noConditionName, String.self).done{ re in
            lock.fulfill()
        }.catch{ err in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }

    func test06_callDataType() {
        let lock = XCTestExpectation(description: "wait for test.")
        scripting?.call(noConditionName, Data.self).done{ data in
            let rejson = try JSONSerialization.jsonObject(with: data , options: .mutableContainers) as AnyObject
            print(rejson)
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ err in
            XCTFail()
            lock.fulfill()
        }
            self.wait(for: [lock], timeout: 10000.0)
    }

    func test07_callOtherScript() {
        let lock = XCTestExpectation(description: "wait for test.")
        scripting?.call(noConditionName, "appId", String.self).done{ str in
            print(str)
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ err in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }

    func test08_setUploadScript() {
        let lock = XCTestExpectation(description: "wait for test.")
        let executable = "{\"type\":\"fileUpload\",\"name\":\"upload_file\",\"output\":true,\"body\":{\"path\":\"$params.path\"}}"
        scripting?.registerScript("upload_file", RawExecutable(executable: executable)).done{ re in
            print(re)
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ err in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }

    func test12_uploadFile() {
        let lock = XCTestExpectation(description: "wait for test.")
        let params = ["name": "upload_file", "params":["group_id": ["$oid": "5f8d9dfe2f4c8b7a6f8ec0f1"], "path": "test.txt"]] as [String : Any]
        scripting!.call("/Users/liaihong/Desktop/test.txt", params, ScriptingType.UPLOAD, String.self).done { re in
            print(re)
            lock.fulfill()
        }.catch{ err in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }

    func test13_setDownloadScript() {
        let executable = DownloadExecutable(name: "download_file", path: "$params.path", output: true)

        let lock = XCTestExpectation(description: "wait for test.")
        scripting!.registerScript("download_file", executable).done { success in
            XCTAssertTrue(success)
            lock.fulfill()
        }.catch { error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }

    func test14_downloadFile() {
        let params = ["group_id": ["$oid": "5f497bb83bd36ab235d82e6a"], "path": "test.txt"] as [String : Any]
        let lock = XCTestExpectation(description: "wait for test.")
        scripting!.call("download_file", params, ScriptingType.DOWNLOAD, String.self).done { success in
//            print(success)
            lock.fulfill()
        }.catch { error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }

    func test15_setInfoScript() {
        let hashExecutable = HashExecutable(name: "file_hash", path: "$params.path")
        let propertiesExecutable = PropertiesExecutable(name: "file_properties", path: "$params.path")
        let executable = AggregatedExecutable("file_properties_and_hash", [hashExecutable, propertiesExecutable])
        let lock = XCTestExpectation(description: "wait for test.")
        scripting!.registerScript("get_file_info", executable).done { success in
            XCTAssertTrue(success)
            lock.fulfill()
        }.catch { error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }

    func test16_getFileInfo() {
        let params = ["group_id": ["$oid": "5f497bb83bd36ab235d82e6a"], "path": "test.txt"] as [String : Any]
        let lock = XCTestExpectation(description: "wait for test.")
        scripting!.call("get_file_info", params, ScriptingType.PROPERTIES, String.self).done { success in
            print(success)
            lock.fulfill()
        }.catch { error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        do {
            user = try UserFactory.createUser1()
            let lock = XCTestExpectation(description: "wait for test.")
            user!.client.getVault(OWNERDID, user?.provider).done { [self] vault in
                self.scripting = (vault.scripting as! ScriptClient)
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
