
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK
/*
class HiveURLTest: XCTestCase {
    private var client: HiveClientHandle?
    private var scripting: Script?
    private var noConditionName: String = "get_groups"
    private var withConditionName: String = "get_group_messages"
    private let testTextFilePath = "/Users/hanongyang/Desktop/test.txt"
    private let downloadUrl = "hive://did:elastos:icXtpDnZRSDrjmD5NQt6TYSphFRqoo2q6n@appId/scripting/download_file?params={\"path\":\"test.txt\"}"
    
    func test_0GetHiveURL() {
        let lock = XCTestExpectation(description: "wait for test.")
        user!.client.parseHiveURL(downloadUrl).done { info in
            print(info)
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch { error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func test_1CallScriptUrl() {
        let scrptingURL = "hive://did:elastos:icXtpDnZRSDrjmD5NQt6TYSphFRqoo2q6n@appId/scripting/get_file_info?params={\"group_id\":{\"$oid\":\"5f497bb83bd36ab235d82e6a\"},\"path\":\"test.txt\"}"
        let hashExecutable = HashExecutable(name: "file_hash", path: "$params.path");
        let propertiesExecutable = PropertiesExecutable(name: "file_properties", path: "$params.path");
        let executable = AggregatedExecutable("file_properties_and_hash", [hashExecutable, propertiesExecutable])
        let lock = XCTestExpectation(description: "wait for test.")
        scripting!.registerScript("get_file_info", executable, false, false).then{ [self] success -> Promise<String> in
            return user!.client.callScriptUrl(scrptingURL, String.self)
        }.done { resultStr in
            print(resultStr)
            lock.fulfill()
        }
        .catch { error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func test_2UploadFile() {
        let executable = UploadExecutable(name: "upload_file", path: "$params.path", output: true)
        let lock = XCTestExpectation(description: "wait for test.")
        let scriptName = "upload_file"
        scripting?.registerScript("upload_file", executable, false, false).then({ [self] success -> Promise<JSON> in
            let param = ["path": "test.txt"]
            return scripting!.callScript(scriptName, param, "appId", JSON.self)
        }).then({ [self] json -> Promise<FileWriter> in
            let transactionId = json[scriptName]["transaction_id"].stringValue
            return scripting!.uploadFile(transactionId)
        }).done({ writer in
            let shortMessage = "POIUYTREWQ"
            let message1 = "*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())*** \(Date())"
            let message2 = " ABCD ABCD ABCD ABCD 1234 5678 9009 8765 0099"
            
            try writer.write(data: shortMessage.data(using: .utf8)!, { err in
                print(err)
            })
            try writer.write(data: message1.data(using: .utf8)!, { err in
                print(err)
            })
            try writer.write(data: message2.data(using: .utf8)!, { err in
                print(err)
            })
            writer.close { (success, error) in
                if success {
                    XCTAssertTrue(success)
                    lock.fulfill()
                }
                else {
                    print(error as Any)
                    XCTFail()
                    lock.fulfill()
                }
            }
        }).catch({ error in
            XCTFail()
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func test_3DownloadFile() {
        let executable = DownloadExecutable(name: "download_file", path: "$params.path", output: true)
        let lock = XCTestExpectation(description: "wait for test.")
        scripting!.registerScript("download_file", executable, false, false).then{ [self] success -> Promise<FileReader> in
            return user!.client.downloadFileByScriptUrl(downloadUrl)
        }.done { [self] reader in
            print(reader)
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
                        lock.fulfill()
                    }
                }
            }
            reader.close { (success, error) in
                lock.fulfill()
                print(success)
            }
            lock.fulfill()
        }
        .catch { error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        do {
            Log.setLevel(.Debug)
            user = try AppInstanceFactory.createUser2()
            let lock = XCTestExpectation(description: "wait for test.")
            user?.client.getVault(user!.userFactoryOpt.ownerDid, user?.userFactoryOpt.provider).done { [self] vault in
                self.scripting = (vault.scripting as! Script)
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
    
    func creaFile() -> URL {
        let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last
        let fileurl = dir?.appendingPathComponent("HiveURLTest_scripting_download_file.txt")
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
*/
