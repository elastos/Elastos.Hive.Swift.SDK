/*
* Copyright (c) 2020 Elastos Foundation
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

private let FIND_NAME: String = "get_group_messages"
private let FIND_NO_CONDITION_NAME: String = "script_no_condition"
private let INSERT_NAME: String = "database_insert"
private let UPDATE_NAME: String = "database_update"
private let DELETE_NAME: String = "database_delete"
private let UPLOAD_FILE_NAME: String = "upload_file"
private let DOWNLOAD_FILE_NAME: String = "download_file"
private let FILE_PROPERTIES_NAME: String = "file_properties"
private let FILE_HASH_NAME: String = "file_hash"
private let DATABASE_NAME: String = "script_database"


class ScriptingServiceTest: XCTestCase {
        
    private var scriptingService: ScriptingProtocol?
    private var filesService: FilesProtocol?
    private var databaseService: DatabaseProtocol?
    private var scriptRunner: ScriptRunner?
    private var fileName: String = "test_ios_1.txt"
    private var localDstFilePath: String = "test_ios_download.txt"
    
    private var COLLECTION_NAME: String = "script_database"
    private var appId: String?
    private var ownerDid: String?
    
    override func setUpWithError() throws {
        Log.setLevel(.Debug)
        let lock = XCTestExpectation(description: "wait for setup.")
        let testData: TestData = TestData.shared
        self.scriptingService = try TestData.shared.newVault().scriptingService
        self.scriptRunner = try testData.newScriptRunner()
        self.filesService = try testData.newVault().filesService
        self.databaseService = try testData.newVault().databaseService

        self.appId = testData.appId
        self.ownerDid = testData.ownerDid

        self.createTestDatabase().done { isSuccess in
            lock.fulfill()
        }.catch { error in
            lock.fulfill()
        }
        
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    // MARK: -
    func test01Insert() {
        let lock = XCTestExpectation(description: "wait for test insert.")
        self.registerScriptInsert(INSERT_NAME).then { isSuccess -> Promise<JSON> in
            return self.callScriptInsert(INSERT_NAME)
        }.done { json in
            XCTAssert(json.description.contains(INSERT_NAME))
            XCTAssert(json[INSERT_NAME]["inserted_id"].string!.count > 0)
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func registerScriptInsert(_ scriptName: String) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let document = ["author" : "$params.author", "content" : "$params.content"]
            let options = ["bypass_document_validation" : false, "ordered" : true]
            let body = ScriptInsertExecutableBody(DATABASE_NAME, document, options)
            let executable = Executable.createInsertExecutable(scriptName, body)
            self.scriptingService!.registerScript(scriptName, nil, executable, false, false).done { isSuccess in
                resolver.fulfill(isSuccess)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    func callScriptInsert(_ scriptName: String) -> Promise<JSON> {
        return Promise<JSON> { resolver in
            let params = ["author" : "John", "content" : "message"]
            self.scriptRunner!.callScript(scriptName, params, self.ownerDid, self.appId, JSON.self).done { json in
                resolver.fulfill(json)
            }.catch { error in
                resolver.reject(error)
            }
        }
        
    }
    
    // MARK: -
    func test02FindWithoutCondition() {
        let lock = XCTestExpectation(description: "wait for test find without condition.")
        self.registerScriptFindWithoutCondition(FIND_NO_CONDITION_NAME).then { isSuccess -> Promise<String> in
            XCTAssert(isSuccess == true, "register script find without condition success")
            return self.callScriptFindWithoutCondition(FIND_NO_CONDITION_NAME)
        }.done { result in
            XCTAssert(result.contains("OK"), "call script find without condition success")
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func registerScriptFindWithoutCondition(_ scriptName: String) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let body = ScriptFindBody(COLLECTION_NAME, ["author" : "John"])
            let executable = Executable(scriptName, Executable.TYPE_FIND, body)
            self.scriptingService!.registerScript(scriptName, nil, executable, false, false).done { isSuccess in
                resolver.fulfill(isSuccess)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    func callScriptFindWithoutCondition(_ scriptName: String) -> Promise<String> {
        return Promise<String> { resolver in
            self.scriptRunner!.callScript(scriptName, nil, self.ownerDid, self.appId, String.self).done { result in
                resolver.fulfill(result)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    // MARK: -
    func test03Find() {
        let lock = XCTestExpectation(description: "wait for test find.")
        self.registerScriptFind(FIND_NAME).then { isSuccess -> Promise<String> in
            XCTAssert(isSuccess == true, "find success")
            return self.callScriptFind(FIND_NAME)
        }.done { result in
            XCTAssert(result.contains("OK"), "call script find success")
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func registerScriptFind(_ scriptName: String) -> Promise<Bool> {
        let filter: Dictionary<String, String> = ["author" : "John"]
        let condition: Condition = Condition("verify_user_permission", "queryHasResults", ScriptFindBody(COLLECTION_NAME, filter))
        let executable: Executable = Executable(scriptName, Executable.TYPE_FIND, ScriptFindBody(COLLECTION_NAME, filter))
        return self.scriptingService!.registerScript(scriptName, condition, executable, false, false)
    }
    
    func callScriptFind(_ scriptName: String) -> Promise<String> {
        return self.scriptRunner!.callScript(scriptName, nil, self.ownerDid, self.appId, String.self)
    }

    
    func testCallScriptFindWithoutCondition(_ scriptName: String) -> Promise<String> {
        return Promise<String> { resolver in
            self.scriptRunner!.callScript(FIND_NO_CONDITION_NAME, nil, self.ownerDid, self.appId, String.self).get({ result in
                resolver.fulfill(result)
            }).catch { error in
                resolver.reject(error)
            }
        }
    }
    
    // MARK: -
    func test04Update()  {
        let lock = XCTestExpectation(description: "wait for test update.")
        self.registerScriptUpdate(UPDATE_NAME).then { isSuccess -> Promise<JSON> in
            return self.callScriptUpdate(UPDATE_NAME)
        }.done { json in
            XCTAssert(json.description.contains(UPDATE_NAME))
            XCTAssert(json[UPDATE_NAME]["upserted_id"].string!.count > 0)
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func registerScriptUpdate(_ scriptName: String) -> Promise<Bool> {
        let body = ScriptUpdateExecutableBody()
        body.collection = DATABASE_NAME
        body.filter = ["author" : "$params.author"]
        body.update = ["$set" : ["author" : "$params.author", "content" : "$params.content"]]
        body.options = ["bypass_document_validation" : false, "upsert" : true]
        let executable = Executable.createUpdateExecutable(scriptName, body)
        return self.scriptingService!.registerScript(scriptName, nil, executable, false, false)
    }

    func callScriptUpdate(_ scriptName: String) -> Promise<JSON> {
        let params = ["author": "John", "content": "message"]
        return self.scriptRunner!.callScript(scriptName, params, self.ownerDid, self.appId, JSON.self)
    }
    
    // MARK: -
    func test05Delete() {
        let lock = XCTestExpectation(description: "wait for test delete.")
        self.registerScriptDelete(DELETE_NAME).then { isSuccess -> Promise<JSON> in
            return self.callScriptDelete(DELETE_NAME)
        }.done { json in
            XCTAssert(json.description.contains(DELETE_NAME))
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func registerScriptDelete(_ scriptName: String) -> Promise<Bool> {
        let body = ScriptDeleteExecutableBody()
        body.collection = DATABASE_NAME
        body.filter = ["author": "$params.author"]
        let executable = Executable.createDeleteExecutable(scriptName, body)
        return self.scriptingService!.registerScript(scriptName, nil, executable, false, false)
    }
    
    func callScriptDelete(_ scriptName: String) -> Promise<JSON> {
        return self.scriptRunner!.callScript(scriptName, ["author" : "John"], self.ownerDid, self.appId, JSON.self)
    }
    
    // MARK: -
    func test06UploadFile() {
        let lock = XCTestExpectation(description: "wait for test upload file.")
        let executable = Executable.createFileUploadExecutable(UPLOAD_FILE_NAME)
        self.scriptingService!.registerScript(UPLOAD_FILE_NAME, nil, executable, false, false).then { [self] result -> Promise<String> in
            return callScriptFileUpload(UPLOAD_FILE_NAME, fileName)
        }.then { transactionId -> Promise<Void> in
            return self.uploadFileByTransActionId(transactionId)
        }.then { _ -> Promise<FileInfo> in
            return self.filesService!.stat(self.fileName)
        }.done { fileInfo in
            print(fileInfo)
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        
        self.wait(for: [lock], timeout: 1000.0)
    }

    func uploadFileByTransActionId(_ transactionId: String) -> Promise<Void> {
        return Promise<Void> { resolver in
            self.scriptRunner!.uploadFile(transactionId, FileWriter.self).done { writer in
                let bundle = Bundle(for: type(of: self))
                let filePath: String = bundle.path(forResource: "test_ios", ofType: "txt")!
                let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
                try writer.write(data: data, { error in
                    print(error)
                })
                writer.close { (success, error) in
                    if error != nil {
                        resolver.reject(error!)
                    }
                    resolver.fulfill(Void())
                }
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    // MARK: -
    func test07FileDownload() {
        let lock = XCTestExpectation(description: "wait for test file download.")

        self.registerScriptFileDownload(DOWNLOAD_FILE_NAME).then({ [self] isSuccess -> Promise<String> in
            return callScriptFileDownload(DOWNLOAD_FILE_NAME, fileName)
        }).then { [self] transactionId -> Promise<Bool> in
            return downloadFileByTransActionId(transactionId)
        }.done { isSuccess in
            
            let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory,
                                               in: FileManager.SearchPathDomainMask.userDomainMask).last!
            let fileURL = dir.appendingPathComponent(self.localDstFilePath)
            let downloadData = try! Data(contentsOf: fileURL)
            let downloadString = String(data: downloadData, encoding: .utf8)
            
            
            let bundle = Bundle(for: type(of: self))
            let filePath: String = bundle.path(forResource: "test_ios", ofType: "txt")!
            let originalData = try! Data(contentsOf: URL(fileURLWithPath: filePath))
            let originalString = String(data: originalData, encoding: .utf8)

            XCTAssert(originalString == downloadString)
            lock.fulfill()
            
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func registerScriptFileDownload(_ scriptName: String) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let executable = Executable.createFileDownloadExecutable(scriptName)
            self.scriptingService!.registerScript(scriptName, nil, executable, false, false).get { isSuccess in
                resolver.fulfill(isSuccess)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    func callScriptFileDownload(_ scriptName: String, _ fileName: String) -> Promise<String> {
        return Promise<String> { resolver in
            let params = Executable.createFileDownloadParams("5f8d9dfe2f4c8b7a6f8ec0f1", fileName)
            self.scriptRunner!.callScript(scriptName, params, self.ownerDid, self.appId, JSON.self).done { json in
                let transactionId = json[scriptName]["transaction_id"].stringValue
                resolver.fulfill(transactionId)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    func downloadFileByTransActionId(_ transactionId: String) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let downloadPath = createDownloadFile(self.localDstFilePath)
            self.scriptRunner!.downloadFile(transactionId, FileReader.self).done({ reader in
                while !reader.didLoadFinish {
                    if let data = reader.read({ error in
                        resolver.reject(error)
                    }) {
                        if let fileHandle = try? FileHandle(forWritingTo: downloadPath) {
                            fileHandle.seekToEndOfFile()
                            fileHandle.write(data)
                            fileHandle.closeFile()
                        }
                    }
                }
                reader.close { (success, error) in
                    if error != nil {
                        resolver.reject(error!)
                    }
                    resolver.fulfill(true)
                }
            }).catch { error in
                resolver.reject(error)
            }
        }
    }
    
    // MARK: -
    func test08testFileHashFileProperties() {
        let lock = XCTestExpectation(description: "wait for test file properties.")
        self.registerScriptFileProperties(FILE_PROPERTIES_NAME).then { isSuccess -> Promise<JSON> in
            return self.callScriptFileProperties(FILE_PROPERTIES_NAME, self.fileName)
        }.done { json in
            XCTAssert(json.description.contains(self.fileName))
            XCTAssert(json["file_properties"]["size"].int! > 0)
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func registerScriptFileProperties(_ scriptName: String) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let executable = Executable.createFilePropertiesExecutable(scriptName)
            self.scriptingService!.registerScript(scriptName, nil, executable, false, false).done { isSuccess in
                resolver.fulfill(isSuccess)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    func callScriptFileProperties(_ scriptName: String, _ fileName: String) -> Promise<JSON> {
        return Promise<JSON> { resolver in
            let params = Executable.createFilePropertiesParams("5f8d9dfe2f4c8b7a6f8ec0f1", fileName)
            self.scriptRunner!.callScript(scriptName, params, self.ownerDid, self.appId, JSON.self).done { json in
                resolver.fulfill(json)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    // MARK: -
    func test09FileHash() {
        let lock = XCTestExpectation(description: "wait for test file hash.")
        self.registerScriptFileHash(FILE_HASH_NAME).then { isSuccess -> Promise<JSON> in
            return self.callScriptFileHash(FILE_HASH_NAME, self.fileName)
        }.done { json in
            XCTAssert(json.description.contains(FILE_HASH_NAME))
            XCTAssert(json.description.contains("SHA256"))
            XCTAssert(json["file_hash"]["SHA256"].string!.count > 0)
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func registerScriptFileHash(_ scriptName: String) -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let executable = Executable.createFileHashExecutable(scriptName)
            self.scriptingService!.registerScript(scriptName, nil, executable, false, false).done { isSuccess in
                resolver.fulfill(isSuccess)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    func callScriptFileHash(_ scriptName: String, _ fileName: String) -> Promise<JSON> {
        return Promise<JSON> { resolver in
            let params = Executable.createFileHashParams("5f8d9dfe2f4c8b7a6f8ec0f1", fileName)
            self.scriptRunner!.callScript(scriptName, params, self.ownerDid, self.appId, JSON.self).done { json in
                resolver.fulfill(json)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    // MARK: -
    func testRegisterScriptFindWithoutCondition(_ scriptName: String) {
        let lock = XCTestExpectation(description: "wait for test register script find without conditon.")
        let executable: Executable = Executable("get_groups", Executable.TYPE_FIND, ScriptFindBody("groups", ["friends" : "$caller_did"]))
        
        self.scriptingService!.registerScript(FIND_NO_CONDITION_NAME, nil, executable, false, false).done({ result in
            XCTAssertTrue(result, "register script find without conditon test case passed")
            lock.fulfill()
        }).catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
    
    func callScriptFileUpload(_ scriptName: String, _ fileName: String) -> Promise<String> {
        return Promise<String> { resolver in
            let params: [String : Any] = ["group_id": ["$oid": "5f8d9dfe2f4c8b7a6f8ec0f1"], "path": self.fileName]
            let scriptName = "upload_file"
            self.scriptRunner!.callScript(scriptName, params, self.ownerDid, self.appId, JSON.self).done { json in
                resolver.fulfill(json[UPLOAD_FILE_NAME]["transaction_id"].stringValue)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    func createTestDatabase() -> Promise<Bool> {
        return Promise<Bool> { resolver in
            self.databaseService!.createCollection(DATABASE_NAME, nil).done { isSuccess in
                resolver.fulfill(isSuccess)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    func removeTestDatabase() -> Promise<Bool> {
        return Promise<Bool> { resolver in
            self.databaseService!.deleteCollection(DATABASE_NAME).done { isSuccess in
                resolver.fulfill(isSuccess)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    func createDownloadFile(_ filePath: String) -> URL {
        let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory,
                                           in: FileManager.SearchPathDomainMask.userDomainMask).last!
        let fileURL = dir.appendingPathComponent(filePath)
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        } else {
            try? FileManager.default.removeItem(atPath: fileURL.path)
            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
        return fileURL
    }
    
    override func tearDownWithError() throws {
        let lock = XCTestExpectation(description: "wait for remove test database.")
        self.removeTestDatabase().done { isSuccess in
            lock.fulfill()
        }.catch { error in
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }
}
