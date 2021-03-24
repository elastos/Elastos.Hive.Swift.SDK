import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class ScriptingServiceTest: XCTestCase {
    let CONDITION_NAME: String = "get_group_messages"
    let NO_CONDITION_NAME: String = "script_no_condition"
    let UPLOAD_FILE_NAME: String = "upload_file"
    let REMOTE_FILE: String = "test_ios0.txt"

    private var scriptingService: ScriptingProtocol?
    private var filesService: FilesProtocol?
    
    func test01_registerScriptFind() {
        do {
            let datafilter = "{\"_id\":\"$params.group_id\",\"friends\":\"$callScripter_did\"}".data(using: String.Encoding.utf8)
            let filter = try JSONSerialization.jsonObject(with: datafilter!,options: .mutableContainers) as? [String : Any]
            let executable: DbFindQuery = DbFindQuery("get_groups", "test_group", filter!)
            let condition: QueryHasResultsCondition = QueryHasResultsCondition("verify_user_permission", "test_group", filter!)
            let lock = XCTestExpectation(description: "wait for test.")
            self.scriptingService?.registerScript(self.CONDITION_NAME, condition, executable, false, false).done({ result in
                XCTAssertTrue(result)
                lock.fulfill()
            }).catch { error in
                print(error)
                XCTFail()
                lock.fulfill()
            }
            self.wait(for: [lock], timeout: 1000.0)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func test02_registerScriptFindWithoutCondition() {
        do {
            let datafilter = "{\"friends\":\"$caller_did\"}".data(using: String.Encoding.utf8)
            let filter = try JSONSerialization.jsonObject(with: datafilter!,options: .mutableContainers) as? [String : Any]
            let dataoptions = "{\"projection\":{\"_id\":false,\"name\":true}}".data(using: String.Encoding.utf8)
            let options = try JSONSerialization.jsonObject(with: dataoptions!,options: .mutableContainers) as? [String : Any]

            let executable: DbFindQuery = DbFindQuery("get_groups", "groups", filter!, options!)
            let lock = XCTestExpectation(description: "wait for test.")
            self.scriptingService?.registerScript(self.NO_CONDITION_NAME, executable, false, false).done({ result in
                XCTAssertTrue(result)
                lock.fulfill()
            }).catch { error in
                print(error)
                XCTFail()
                lock.fulfill()
            }
            self.wait(for: [lock], timeout: 1000.0)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func test03_callScriptFindWithoutCondition() {
        let lock = XCTestExpectation(description: "wait for test.")
        self.scriptingService?.callScript(self.NO_CONDITION_NAME, nil, "appId", String.self).done({ (string) in
            if string.count > 0 {
                XCTAssertTrue(true)
            } else {
                XCTFail()
            }
            print(string)
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func test03_callScriptUrlFindWithoutCondition() {
        let lock = XCTestExpectation(description: "wait for test.")
        self.scriptingService?.callScriptUrl(self.UPLOAD_FILE_NAME, nil, "appId", String.self).done({ (string) in
            if string.count > 0 {
                XCTAssertTrue(true)
            } else {
                XCTFail()
            }
            print(string)
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    // TODO:
    func test03_uploadFile() {
        
        let lockA = XCTestExpectation(description: "wait for test.")
        let executable = UploadExecutable(name: "upload_file", path: "$params.path", output: true)
        self.scriptingService?.registerScript("upload_file", executable, false, false).done { re in
            lockA.fulfill()
        }.catch{ err in
            XCTFail()
            lockA.fulfill()
        }
        self.wait(for: [lockA], timeout: 1000.0)
        
        var transactionId = ""
        let lockB = XCTestExpectation(description: "wait for test.")
        var params = ["group_id": ["$oid": "5f8d9dfe2f4c8b7a6f8ec0f1"], "path": "test_ios0.txt"] as [String : Any]
        let scriptName = "upload_file"
        self.scriptingService?.callScript(scriptName, params, "appId", JSON.self).done({ json in
            transactionId = json[scriptName]["transaction_id"].stringValue
            print(transactionId)
            lockB.fulfill()
        })
        self.wait(for: [lockB], timeout: 1000.0)
        
        let lockC = XCTestExpectation(description: "wait for test.")
        let bundle = Bundle(for: type(of: self))
        let filePath: String = bundle.path(forResource: "test_ios", ofType: "txt")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        
        self.scriptingService?.uploadFile(transactionId).done({ (writer) in
            try writer.write(data: data, { error in
                print(error)
            })
            writer.close { (success, error) in
                print(success)
                lockC.fulfill()
            }
        })
        self.wait(for: [lockC], timeout: 1000.0)

        let lockD = XCTestExpectation(description: "wait for test.")

        let executableA = DownloadExecutable(name: "download_file", path: "$params.path", output: true)

        self.scriptingService!.registerScript("download_file", executableA, false, false).done { success in
            XCTAssertTrue(success)
            lockD.fulfill()
        }.catch { error in
            XCTFail()
            lockD.fulfill()
        }
        self.wait(for: [lockD], timeout: 10000.0)
        
        let lockE = XCTestExpectation(description: "wait for test.")
        params = ["group_id": ["$oid": "5f497bb83bd36ab235d82e6a"], "path": "test_ios0.txt"] as [String : Any]
        self.scriptingService?.callScript("download_file", params, "appId", JSON.self).done({ json in
            transactionId = json["download_file"]["transaction_id"].stringValue
            self.scriptingService?.downloadFile(transactionId).done({ (reader) in
                let fileurl = creaFile()
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
                            lockE.fulfill()
                        }
                    }
                }
                reader.close { (success, error) in
                    lockE.fulfill()
                    print(success)
                }
            })
        })
        
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
        

//        return Promise<FileReader> { resolver in
//            let url = URL(string: vaultUrl.download(remoteFile))
//            guard (url != nil) else {
//                resolver.reject(HiveError.IllegalArgument(des: "Invalid url format."))
//                return
//            }
//            reader = FileReader(url: url!, authHelper: authHelper, method: .get, resolver: resolver)
//            reader?.authFailure = { error in
//                if tryAgain >= 1 {
//                    resolver.reject(error)
//                    return
//                }
//                self.authHelper.retryLogin().then { success -> Promise<FileReader> in
//                    return self.downloadImp(remoteFile, tryAgain: 1)
//                }.done { result in
//                    resolver.fulfill(result)
//                }.catch { error in
//                    resolver.reject(error)
//                }
//            }
//        }
        
//        let lockE = XCTestExpectation(description: "wait for test.")
//        self.filesService?.stat(REMOTE_FILE).done({ (fileInfo) in
//            print(fileInfo)
//            lockE.fulfill()
//        })
        self.wait(for: [lockE], timeout: 10000.0)

    }
    
    func registerScriptFileUpload() {
        
    }
        
    override func setUpWithError() throws {
        Log.setLevel(.Debug)
        let lockA = XCTestExpectation(description: "wait for test.")
        _ = TestData.shared.getVault().done { (vault) in
            self.scriptingService = vault.scripting
            
            _ = try vault.connectionManager.headers()
            lockA.fulfill()
        }
        self.wait(for: [lockA], timeout: 1000.0)

        let lockB = XCTestExpectation(description: "wait for test.")
        _ = TestData.shared.getVault().done { (vault) in
            self.filesService = vault.filesService
            lockB.fulfill()
        }
        self.wait(for: [lockB], timeout: 1000.0)
    }    
}
