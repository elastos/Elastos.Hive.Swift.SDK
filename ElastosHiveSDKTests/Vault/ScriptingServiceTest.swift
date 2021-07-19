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
import AwaitKit

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
        
    private var _scriptingService: ScriptingService?
    private var _filesService: FilesService?
    private var _databaseService: DatabaseService?
    private var _scriptRunner: ScriptRunner?
    private var fileName: String = "test_ios_1.txt"
    private var localDstFilePath: String = "test_ios_download.txt"
    
    private var COLLECTION_NAME: String = "script_database"
    private var _appDid: String?
    private var _targetDid: String?
    
    private let _collectionName: String = "script_database";


    
    override func setUpWithError() throws {
        XCTAssertNoThrow({ [self] in
            let testData = TestData.shared()
            _scriptingService = testData.newVault().scriptingService
            _scriptRunner = testData.newScriptRunner()
            _filesService = testData.newVault().filesService
            _databaseService = testData.newVault().databaseService
            _appDid = testData.appId
            _targetDid = testData.userDid
        })
    }
    
    public func test01Insert() {
        remove_test_database();
        create_test_database();
        registerScriptInsert(INSERT_NAME);
        callScriptInsert(INSERT_NAME);
    }
    
    private func registerScriptInsert(_ scriptName: String) {
        XCTAssertNoThrow({ [self] in
            let doc = ["author" : "$params.author", "content" : "$params.content"]
            let options = ["bypass_document_validation" : false, "ordered" : true]
            try await(_scriptingService!.registerScript(scriptName, InsertExecutable(scriptName, _collectionName, doc, options), false, false))
        })
    }
    
    private func callScriptInsert(_ scriptName: String) {
        XCTAssertNoThrow({ [self] in
            let params = ["author" : "John", "content" : "message"]
            let result = try await(_scriptRunner!.callScript(scriptName, params, _targetDid!, _appDid!,  JSON.self))
            XCTAssertNotNil(result)
            XCTAssert(result[scriptName] != nil)
            XCTAssert(result[scriptName]["inserted_id"] != nil)
        })
    }

    private func registerScriptFindWithoutCondition(_ scriptName: String) {
        XCTAssertNoThrow({ [self] in
            let filter = ["author" : "John"]
            let result = try await(_scriptingService!.registerScript(scriptName, FindExecutable(scriptName, _collectionName, filter), false, false))
        })
    }
    
    public func test02FindWithoutCondition() {
        registerScriptFindWithoutCondition(FIND_NO_CONDITION_NAME)
        callScriptFindWithoutCondition(FIND_NO_CONDITION_NAME)
    }
    
    private func callScriptFindWithoutCondition(_ scriptName: String) {
        XCTAssertNoThrow({ [self] in
            _ = try await(_scriptRunner!.callScriptUrl(scriptName, "{}", _targetDid!, _appDid!, String.self))
        })
    }
    
    public func test03Find() {
        registerScriptFind(FIND_NAME)
        callScriptFind(FIND_NAME)
    }
    
    private func registerScriptFind(_ scriptName: String) {
        XCTAssertNoThrow({ [self] in
            let filter = ["author" : "John"]
            _ = try await(_scriptingService!.registerScript(scriptName, QueryHasResultCondition("verify_user_permission", COLLECTION_NAME, filter), FindExecutable(scriptName, COLLECTION_NAME, filter), false, false))
        })
    }
    
    private func callScriptFind(_ scriptName: String) {
        XCTAssertNoThrow({ [self] in
            XCTAssertNotNil(try await(_scriptRunner!.callScript(scriptName, nil, _targetDid!, _appDid!, String.self)))
        })
    }
    
    public func test04Update() {
        registerScriptUpdate(UPDATE_NAME)
        callScriptUpdate(UPDATE_NAME)
    }

    private func registerScriptUpdate(_ scriptName: String) {
        XCTAssertNoThrow({ [self] in
            let filter = ["author" : "$params.author"]
            let set = ["author" : "$params.author", "content" : "$params.content"]
            let update = ["$set" : set]
            let options = ["bypass_document_validation" : false, "upsert" :true]
            _ = try await(_scriptingService!.registerScript(scriptName, UpdateExecutable(scriptName, COLLECTION_NAME, filter, update, options), false, false))
        })
    }
    
    private func callScriptUpdate(_ scriptName: String) {
        XCTAssertNoThrow({ [self] in
            let params = ["author" : "John", "content" : "message"]
            let result = try await(_scriptRunner!.callScript(scriptName, params, _targetDid!, _appDid!, JSON.self))
            XCTAssertNotNil(result)
            XCTAssert(result[scriptName] != nil)
            XCTAssert(result[scriptName]["upserted_id"] != nil)
        })
    }
    
    public func test05Delete() {
        registerScriptDelete(DELETE_NAME)
        callScriptDelete(DELETE_NAME)
    }
    
    private func registerScriptDelete(_ scriptName: String) {
        XCTAssertNoThrow({ [self] in
            let filter = ["author" : "$params.author"]
            try await(_scriptingService!.registerScript(scriptName, DeleteExecutable(scriptName, COLLECTION_NAME, filter), false, false))
        })
    }
   
    private func callScriptDelete(_ scriptName: String) {
        XCTAssertNoThrow({ [self] in
            let params = ["author" : "John"]
            let result = try await(_scriptRunner!.callScript(scriptName, params, _targetDid!, _appDid!, JSON.self))
            XCTAssertNotNil(result)
            XCTAssert(result[scriptName] != nil)
            XCTAssert(result[scriptName]["deleted_count"] != nil)
        })
    }

    private func registerScriptFileUpload(_ scriptName: String) {
        XCTAssertNoThrow({ [self] in
            try await(_scriptingService!.registerScript(scriptName, FileUploadExecutable(scriptName).setOutput(true), false, false))
        })
    }

    private func callScriptFileUpload(_ scriptName: String, _ fileName: String) -> String {
        do {
            let result = try await(_scriptRunner!.callScript(scriptName, Executable.createRunFileParams(fileName), _targetDid!, _appDid!, JSON.self))
            XCTAssertNotNil(result)
            XCTAssert(result[scriptName] != nil)
            XCTAssert(result[scriptName]["transaction_id"] != nil)
            return result[scriptName]["transaction_id"].string!
            
        } catch {
            print(error)
        }

    }
    
    private func uploadFileByTransActionId(_ transactionId: String) {
        
    }
    
    public func test08FileProperties() {
        registerScriptFileProperties(FILE_PROPERTIES_NAME)
        callScriptFileProperties(FILE_PROPERTIES_NAME, fileName)
    }
    
    public func registerScriptFileProperties(_ scriptName: String) {
        XCTAssertNoThrow({ [self] in
            _scriptingService?.registerScript(scriptName, FilePropertiesExecutable(scriptName).setOutput(true), false, false)
        })
    }

    public func callScriptFileProperties(_ scriptName: String, _ fileName: String) {
        XCTAssertNoThrow({ [self] in
            let result = try await(_scriptRunner!.callScript(scriptName, Executable.createRunFileParams(fileName), _targetDid!, _appDid!, JSON.self))
            XCTAssertNotNil(result)
            XCTAssert(result[scriptName] != nil)
            XCTAssert(((result[scriptName].string?.contains("size")) != nil))
        })
    }
    
    public func test09FileHash() {
        registerScriptFileHash(FILE_HASH_NAME)
        callScriptFileHash(FILE_HASH_NAME, fileName)
    }

    private func registerScriptFileHash(_ scriptName: String) {
        XCTAssertNoThrow({ [self] in
            _scriptingService?.registerScript(scriptName, FileHashExecutable(scriptName).setOutput(true), false, false)
        })
    }
    
    private func callScriptFileHash(_ scriptName: String, _ fileName: String) {
        XCTAssertNoThrow({ [self] in
            let result = try await(_scriptRunner!.callScript(scriptName, Executable.createRunFileParams(fileName), _targetDid!, _appDid!, JSON.self))
            XCTAssertNotNil(result)
            XCTAssert(result[scriptName] != nil)
            XCTAssert(((result[scriptName].string?.contains("SHA256")) != nil))
        })
    }
    
    public func test10Unregister() {
        XCTAssertNoThrow({ [self] in
            try await(_scriptingService!.unregisterScript(FILE_HASH_NAME))
            remove_test_database();
        })
    }
    
    /**
     * If exists, also return OK(_status).
     */
    public func create_test_database() {
        do {
            _ = try await(_databaseService!.createCollection(_collectionName))
        } catch {
            print("Failed to create collection: \(error)")
        }
    }

    /**
     * If not exists, also return OK(_status).
     */
    public func remove_test_database() {
        do {
            _ = try await(_databaseService!.deleteCollection(_collectionName))
        } catch {
            print("Failed to remove collection: \(error)")
        }
    }
    
//    // MARK: -
//    func test01Insert() {
//        let lock = XCTestExpectation(description: "wait for test insert.")
//        self.registerScriptInsert(INSERT_NAME).then { isSuccess -> Promise<JSON> in
//            return self.callScriptInsert(INSERT_NAME)
//        }.done { json in
//            XCTAssert(json.description.contains(INSERT_NAME))
//            XCTAssert(json[INSERT_NAME]["inserted_id"].string!.count > 0)
//            lock.fulfill()
//        }.catch { error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//
//    func registerScriptInsert(_ scriptName: String) -> Promise<Bool> {
//        return Promise<Bool> { resolver in
//            let document = ["author" : "$params.author", "content" : "$params.content"]
//            let options = ["bypass_document_validation" : false, "ordered" : true]
//            let body = ScriptInsertExecutableBody(DATABASE_NAME, document, options)
//            let executable = Executable.createInsertExecutable(scriptName, body)
//            self.scriptingService!.registerScript(scriptName, nil, executable, false, false).done { isSuccess in
//                resolver.fulfill(isSuccess)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//    func callScriptInsert(_ scriptName: String) -> Promise<JSON> {
//        return Promise<JSON> { resolver in
//            let params = ["author" : "John", "content" : "message"]
//            self.scriptRunner!.callScript(scriptName, params, self.ownerDid, self.appId, JSON.self).done { json in
//                resolver.fulfill(json)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//
//    }
//
//    // MARK: -
//    func test02FindWithoutCondition() {
//        let lock = XCTestExpectation(description: "wait for test find without condition.")
//        self.registerScriptFindWithoutCondition(FIND_NO_CONDITION_NAME).then { isSuccess -> Promise<String> in
//            XCTAssert(isSuccess == true, "register script find without condition success")
//            return self.callScriptFindWithoutCondition(FIND_NO_CONDITION_NAME)
//        }.done { result in
//            XCTAssert(result.contains("OK"), "call script find without condition success")
//            lock.fulfill()
//        }.catch { error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//
//    func registerScriptFindWithoutCondition(_ scriptName: String) -> Promise<Bool> {
//        return Promise<Bool> { resolver in
//            let body = ScriptFindBody(COLLECTION_NAME, ["author" : "John"])
//            let executable = Executable(scriptName, Executable.TYPE_FIND, body)
//            self.scriptingService!.registerScript(scriptName, nil, executable, false, false).done { isSuccess in
//                resolver.fulfill(isSuccess)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//    func callScriptFindWithoutCondition(_ scriptName: String) -> Promise<String> {
//        return Promise<String> { resolver in
//            self.scriptRunner!.callScript(scriptName, nil, self.ownerDid, self.appId, String.self).done { result in
//                resolver.fulfill(result)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//    // MARK: -
//    func test03Find() {
//        let lock = XCTestExpectation(description: "wait for test find.")
//        self.registerScriptFind(FIND_NAME).then { isSuccess -> Promise<String> in
//            XCTAssert(isSuccess == true, "find success")
//            return self.callScriptFind(FIND_NAME)
//        }.done { result in
//            XCTAssert(result.contains("OK"), "call script find success")
//            lock.fulfill()
//        }.catch { error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//
//    func registerScriptFind(_ scriptName: String) -> Promise<Bool> {
//        let filter: Dictionary<String, String> = ["author" : "John"]
//        let condition: Condition = Condition("verify_user_permission", "queryHasResults", ScriptFindBody(COLLECTION_NAME, filter))
//        let executable: Executable = Executable(scriptName, Executable.TYPE_FIND, ScriptFindBody(COLLECTION_NAME, filter))
//        return self.scriptingService!.registerScript(scriptName, condition, executable, false, false)
//    }
//
//    func callScriptFind(_ scriptName: String) -> Promise<String> {
//        return self.scriptRunner!.callScript(scriptName, nil, self.ownerDid, self.appId, String.self)
//    }
//
//
//    func testCallScriptFindWithoutCondition(_ scriptName: String) -> Promise<String> {
//        return Promise<String> { resolver in
//            self.scriptRunner!.callScript(FIND_NO_CONDITION_NAME, nil, self.ownerDid, self.appId, String.self).get({ result in
//                resolver.fulfill(result)
//            }).catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//    // MARK: -
//    func test04Update()  {
//        let lock = XCTestExpectation(description: "wait for test update.")
//        self.registerScriptUpdate(UPDATE_NAME).then { isSuccess -> Promise<JSON> in
//            return self.callScriptUpdate(UPDATE_NAME)
//        }.done { json in
//            XCTAssert(json.description.contains(UPDATE_NAME))
//            XCTAssert(json[UPDATE_NAME]["upserted_id"].string!.count > 0)
//            lock.fulfill()
//        }.catch { error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//
//    func registerScriptUpdate(_ scriptName: String) -> Promise<Bool> {
//        let body = ScriptUpdateExecutableBody()
//        body.collection = DATABASE_NAME
//        body.filter = ["author" : "$params.author"]
//        body.update = ["$set" : ["author" : "$params.author", "content" : "$params.content"]]
//        body.options = ["bypass_document_validation" : false, "upsert" : true]
//        let executable = Executable.createUpdateExecutable(scriptName, body)
//        return self.scriptingService!.registerScript(scriptName, nil, executable, false, false)
//    }
//
//    func callScriptUpdate(_ scriptName: String) -> Promise<JSON> {
//        let params = ["author": "John", "content": "message"]
//        return self.scriptRunner!.callScript(scriptName, params, self.ownerDid, self.appId, JSON.self)
//    }
//
//    // MARK: -
//    func test05Delete() {
//        let lock = XCTestExpectation(description: "wait for test delete.")
//        self.registerScriptDelete(DELETE_NAME).then { isSuccess -> Promise<JSON> in
//            return self.callScriptDelete(DELETE_NAME)
//        }.done { json in
//            XCTAssert(json.description.contains(DELETE_NAME))
//            lock.fulfill()
//        }.catch { error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//
//    func registerScriptDelete(_ scriptName: String) -> Promise<Bool> {
//        let body = ScriptDeleteExecutableBody()
//        body.collection = DATABASE_NAME
//        body.filter = ["author": "$params.author"]
//        let executable = Executable.createDeleteExecutable(scriptName, body)
//        return self.scriptingService!.registerScript(scriptName, nil, executable, false, false)
//    }
//
//    func callScriptDelete(_ scriptName: String) -> Promise<JSON> {
//        return self.scriptRunner!.callScript(scriptName, ["author" : "John"], self.ownerDid, self.appId, JSON.self)
//    }
//
//    // MARK: -
//    func test06UploadFile() {
//        let lock = XCTestExpectation(description: "wait for test upload file.")
//        let executable = Executable.createFileUploadExecutable(UPLOAD_FILE_NAME)
//        self.scriptingService!.registerScript(UPLOAD_FILE_NAME, nil, executable, false, false).then { [self] result -> Promise<String> in
//            return callScriptFileUpload(UPLOAD_FILE_NAME, fileName)
//        }.then { transactionId -> Promise<Void> in
//            return self.uploadFileByTransActionId(transactionId)
//        }.then { _ -> Promise<FileInfo> in
//            return self.filesService!.stat(self.fileName)
//        }.done { fileInfo in
//            print(fileInfo)
//            lock.fulfill()
//        }.catch { error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        }
//
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//
//    func uploadFileByTransActionId(_ transactionId: String) -> Promise<Void> {
//        return Promise<Void> { resolver in
//            self.scriptRunner!.uploadFile(transactionId, FileWriter.self).done { writer in
//                let bundle = Bundle(for: type(of: self))
//                let filePath: String = bundle.path(forResource: "test_ios", ofType: "txt")!
//                let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
//                try writer.write(data: data, { error in
//                    print(error)
//                })
//                writer.close { (success, error) in
//                    if error != nil {
//                        resolver.reject(error!)
//                    }
//                    resolver.fulfill(Void())
//                }
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//    // MARK: -
//    func test07FileDownload() {
//        let lock = XCTestExpectation(description: "wait for test file download.")
//
//        self.registerScriptFileDownload(DOWNLOAD_FILE_NAME).then({ [self] isSuccess -> Promise<String> in
//            return callScriptFileDownload(DOWNLOAD_FILE_NAME, fileName)
//        }).then { [self] transactionId -> Promise<Bool> in
//            return downloadFileByTransActionId(transactionId)
//        }.done { isSuccess in
//
//            let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory,
//                                               in: FileManager.SearchPathDomainMask.userDomainMask).last!
//            let fileURL = dir.appendingPathComponent(self.localDstFilePath)
//            let downloadData = try! Data(contentsOf: fileURL)
//            let downloadString = String(data: downloadData, encoding: .utf8)
//
//
//            let bundle = Bundle(for: type(of: self))
//            let filePath: String = bundle.path(forResource: "test_ios", ofType: "txt")!
//            let originalData = try! Data(contentsOf: URL(fileURLWithPath: filePath))
//            let originalString = String(data: originalData, encoding: .utf8)
//
//            XCTAssert(originalString == downloadString)
//            lock.fulfill()
//
//        }.catch { error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//
//    func registerScriptFileDownload(_ scriptName: String) -> Promise<Bool> {
//        return Promise<Bool> { resolver in
//            let executable = Executable.createFileDownloadExecutable(scriptName)
//            self.scriptingService!.registerScript(scriptName, nil, executable, false, false).get { isSuccess in
//                resolver.fulfill(isSuccess)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//    func callScriptFileDownload(_ scriptName: String, _ fileName: String) -> Promise<String> {
//        return Promise<String> { resolver in
//            let params = Executable.createFileDownloadParams("5f8d9dfe2f4c8b7a6f8ec0f1", fileName)
//            self.scriptRunner!.callScript(scriptName, params, self.ownerDid, self.appId, JSON.self).done { json in
//                let transactionId = json[scriptName]["transaction_id"].stringValue
//                resolver.fulfill(transactionId)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//    func downloadFileByTransActionId(_ transactionId: String) -> Promise<Bool> {
//        return Promise<Bool> { resolver in
//            let downloadPath = createDownloadFile(self.localDstFilePath)
//            self.scriptRunner!.downloadFile(transactionId, FileReader.self).done({ reader in
//                while !reader.didLoadFinish {
//                    if let data = reader.read({ error in
//                        resolver.reject(error)
//                    }) {
//                        if let fileHandle = try? FileHandle(forWritingTo: downloadPath) {
//                            fileHandle.seekToEndOfFile()
//                            fileHandle.write(data)
//                            fileHandle.closeFile()
//                        }
//                    }
//                }
//                reader.close { (success, error) in
//                    if error != nil {
//                        resolver.reject(error!)
//                    }
//                    resolver.fulfill(true)
//                }
//            }).catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//    // MARK: -
//    func test08testFileHashFileProperties() {
//        let lock = XCTestExpectation(description: "wait for test file properties.")
//        self.registerScriptFileProperties(FILE_PROPERTIES_NAME).then { isSuccess -> Promise<JSON> in
//            return self.callScriptFileProperties(FILE_PROPERTIES_NAME, self.fileName)
//        }.done { json in
//            XCTAssert(json.description.contains(self.fileName))
//            XCTAssert(json["file_properties"]["size"].int! > 0)
//            lock.fulfill()
//        }.catch { error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//
//    func registerScriptFileProperties(_ scriptName: String) -> Promise<Bool> {
//        return Promise<Bool> { resolver in
//            let executable = Executable.createFilePropertiesExecutable(scriptName)
//            self.scriptingService!.registerScript(scriptName, nil, executable, false, false).done { isSuccess in
//                resolver.fulfill(isSuccess)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//    func callScriptFileProperties(_ scriptName: String, _ fileName: String) -> Promise<JSON> {
//        return Promise<JSON> { resolver in
//            let params = Executable.createFilePropertiesParams("5f8d9dfe2f4c8b7a6f8ec0f1", fileName)
//            self.scriptRunner!.callScript(scriptName, params, self.ownerDid, self.appId, JSON.self).done { json in
//                resolver.fulfill(json)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//    // MARK: -
//    func test09FileHash() {
//        let lock = XCTestExpectation(description: "wait for test file hash.")
//        self.registerScriptFileHash(FILE_HASH_NAME).then { isSuccess -> Promise<JSON> in
//            return self.callScriptFileHash(FILE_HASH_NAME, self.fileName)
//        }.done { json in
//            XCTAssert(json.description.contains(FILE_HASH_NAME))
//            XCTAssert(json.description.contains("SHA256"))
//            XCTAssert(json["file_hash"]["SHA256"].string!.count > 0)
//            lock.fulfill()
//        }.catch { error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//
//    func registerScriptFileHash(_ scriptName: String) -> Promise<Bool> {
//        return Promise<Bool> { resolver in
//            let executable = Executable.createFileHashExecutable(scriptName)
//            self.scriptingService!.registerScript(scriptName, nil, executable, false, false).done { isSuccess in
//                resolver.fulfill(isSuccess)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//    func callScriptFileHash(_ scriptName: String, _ fileName: String) -> Promise<JSON> {
//        return Promise<JSON> { resolver in
//            let params = Executable.createFileHashParams("5f8d9dfe2f4c8b7a6f8ec0f1", fileName)
//            self.scriptRunner!.callScript(scriptName, params, self.ownerDid, self.appId, JSON.self).done { json in
//                resolver.fulfill(json)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//
//
//
//
//
//
//
//
//
//    // MARK: -
//    func testRegisterScriptFindWithoutCondition(_ scriptName: String) {
//        let lock = XCTestExpectation(description: "wait for test register script find without conditon.")
//        let executable: Executable = Executable("get_groups", Executable.TYPE_FIND, ScriptFindBody("groups", ["friends" : "$caller_did"]))
//
//        self.scriptingService!.registerScript(FIND_NO_CONDITION_NAME, nil, executable, false, false).done({ result in
//            XCTAssertTrue(result, "register script find without conditon test case passed")
//            lock.fulfill()
//        }).catch { error in
//            XCTFail("\(error)")
//            lock.fulfill()
//        }
//        self.wait(for: [lock], timeout: 1000.0)
//    }
//
//    func callScriptFileUpload(_ scriptName: String, _ fileName: String) -> Promise<String> {
//        return Promise<String> { resolver in
//            let params: [String : Any] = ["group_id": ["$oid": "5f8d9dfe2f4c8b7a6f8ec0f1"], "path": self.fileName]
//            let scriptName = "upload_file"
//            self.scriptRunner!.callScript(scriptName, params, self.ownerDid, self.appId, JSON.self).done { json in
//                resolver.fulfill(json[UPLOAD_FILE_NAME]["transaction_id"].stringValue)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//    func createTestDatabase() -> Promise<Bool> {
//        return Promise<Bool> { resolver in
//            self.databaseService!.createCollection(DATABASE_NAME, nil).done { isSuccess in
//                resolver.fulfill(isSuccess)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//    func removeTestDatabase() -> Promise<Bool> {
//        return Promise<Bool> { resolver in
//            self.databaseService!.deleteCollection(DATABASE_NAME).done { isSuccess in
//                resolver.fulfill(isSuccess)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
//
//    func createDownloadFile(_ filePath: String) -> URL {
//        let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory,
//                                           in: FileManager.SearchPathDomainMask.userDomainMask).last!
//        let fileURL = dir.appendingPathComponent(filePath)
//        if !FileManager.default.fileExists(atPath: fileURL.path) {
//            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
//        } else {
//            try? FileManager.default.removeItem(atPath: fileURL.path)
//            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
//        }
//        return fileURL
//    }
//
    override func tearDownWithError() throws {
//        let lock = XCTestExpectation(description: "wait for remove test database.")
//        self.removeTestDatabase().done { isSuccess in
//            lock.fulfill()
//        }.catch { error in
//            lock.fulfill()
//        }
//        self.wait(for: [lock], timeout: 1000.0)
    }
}
