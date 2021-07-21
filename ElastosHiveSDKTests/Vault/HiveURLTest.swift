import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class HiveURLTest: XCTestCase {
    let SCRIPT_URL = "hive://did:elastos:iqcpzTBTbi27exRoP27uXMLNM1r3w3UwaL@appId/get_file_info?" +
            "params={\"group_id\":{\"$oid\":\"5f497bb83bd36ab235d82e6a\"},\"path\":\"" + "hello/test.txt" + "\"}"
    let SCRIPT_URL_DOWNLOAD = "hive://did:elastos:iqcpzTBTbi27exRoP27uXMLNM1r3w3UwaL@appId/download_file?" +
            "params={\"group_id\":{\"$oid\":\"5f497bb83bd36ab235d82e6a\"},\"path\":\"" + "hello/test.txt" + "\"}"
    private var scripting: ScriptClient!
    
    override func setUp() {
        do {
            Log.setLevel(.Debug)
            user = try AppInstanceFactory.createUser1()
            let lock = XCTestExpectation(description: "wait for test.")
            user?.client.getVault(user!.userFactoryOpt.ownerDid, user?.userFactoryOpt.provider).done { [self] vault in
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
    
    func testGetHiveURL() {
        let lock = XCTestExpectation(description: "wait for test.")
        user?.client.parseHiveURL(SCRIPT_URL).done { hiveInfo in
            print(hiveInfo)
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch { error in
            print(error)
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func testCallScriptUrl() {
        let lock = XCTestExpectation(description: "wait for test.")
        let scriptName = "get_file_info";
        let hashExecutable = HashExecutable(name: "file_hash", path: "$params.path", output: true)
        let propertiesExecutable = PropertiesExecutable(name: "file_properties", path: "$params.path", output: true)
        let executable = AggregatedExecutable("file_properties_and_hash", [hashExecutable, propertiesExecutable])
        scripting.registerScript(scriptName, executable, false, false).then { [self] succ -> Promise<[String: Any]> in
            return (user?.client.callScriptUrl(SCRIPT_URL, [String: Any].self))!
        }.done { result in
            print(result)
            XCTAssertTrue(true)
            lock.fulfill()
        }
        .catch { error in
            print(error)
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }

    func testCallScriptUrl4Download() {
        let lock = XCTestExpectation(description: "wait for test.")
        let scriptName = "download_file";
        let executable = DownloadExecutable(name: "download_file", path: "$params.path", output: true)
        scripting.registerScript(scriptName, executable, false, false).then { [self] succ -> Promise<FileReader> in
            return (user?.client.downloadFileByScriptUrl(SCRIPT_URL_DOWNLOAD))!
        }.done { [self] reader in
            print(reader)
            let fileurl = creaFile()
            print("fileurl == \(fileurl)")
            while !reader.didLoadFinish {
                if let data = reader.read({ error in
                    print(error)
                }){
                    if let fileHandle = try? FileHandle(forWritingTo: fileurl) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    } else {
                        XCTFail()
                        lock.fulfill()
                    }
                }
            }
            reader.close { (success, error) in
                lock.fulfill()
                print(success)
            }
            XCTAssertTrue(true)
            lock.fulfill()
        }
        .catch { error in
            print(error)
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func creaFile() -> URL {
        let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last
        let fileurl = dir?.appendingPathComponent("scripting_download_file.txt")
        if !FileManager.default.fileExists(atPath: fileurl!.path) {
            FileManager.default.createFile(atPath: fileurl!.path, contents: nil, attributes: nil)
        }
        else {
            try? FileManager.default.removeItem(atPath: fileurl!.path)
            FileManager.default.createFile(atPath: fileurl!.path, contents: nil, attributes: nil)
        }
        
        print("fileurl == \(fileurl)")
        return fileurl!
    }
}
