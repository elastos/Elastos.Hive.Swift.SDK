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
        }())
    }
    
    public func test01Insert() {
        remove_test_database();
        create_test_database();
        registerScriptInsert(INSERT_NAME);
        callScriptInsert(INSERT_NAME);
    }
    
    private func registerScriptInsert(_ scriptName: String) {
        XCTAssertNoThrow(try { [self] in
            let doc = ["author" : "$params.author", "content" : "$params.content"]
            let options = ["bypass_document_validation" : false, "ordered" : true]
            try await(_scriptingService!.registerScript(scriptName, InsertExecutable(scriptName, _collectionName, doc, options), false, false))
        }())
    }
    
    private func callScriptInsert(_ scriptName: String) {
        XCTAssertNoThrow(try { [self] in
            let params = ["author" : "John", "content" : "message"]
            let result = try await(_scriptRunner!.callScript(scriptName, params, _targetDid!, _appDid!, JSON.self))
            XCTAssertNotNil(result)
            XCTAssert(result[scriptName] != nil)
            XCTAssert(result[scriptName]["inserted_id"] != nil)
        }())
    }

    public func test02FindWithoutCondition() {
        registerScriptFindWithoutCondition(FIND_NO_CONDITION_NAME)
        callScriptFindWithoutCondition(FIND_NO_CONDITION_NAME)
    }
    
    private func registerScriptFindWithoutCondition(_ scriptName: String) {
        XCTAssertNoThrow(try { [self] in
            let filter = ["author" : "John"]
            let result = try await(_scriptingService!.registerScript(scriptName, FindExecutable(scriptName, _collectionName, filter), false, false))
        }())
    }
    
    private func callScriptFindWithoutCondition(_ scriptName: String) {
        XCTAssertNoThrow(try { [self] in
            _ = try await(_scriptRunner!.callScriptUrl(scriptName, "{}", _targetDid!, _appDid!, String.self))
        }())
    }
    
    public func test03Find() {
        registerScriptFind(FIND_NAME)
        callScriptFind(FIND_NAME)
    }
    
    private func registerScriptFind(_ scriptName: String) {
        XCTAssertNoThrow(try { [self] in
            let filter = ["author" : "John"]
            _ = try await(_scriptingService!.registerScript(scriptName, QueryHasResultCondition("verify_user_permission", COLLECTION_NAME, filter), FindExecutable(scriptName, COLLECTION_NAME, filter).setOutput(true), false, false))
        }())
    }
    
    private func callScriptFind(_ scriptName: String) {
        XCTAssertNoThrow(try { [self] in
            XCTAssertNotNil(try await(_scriptRunner!.callScript(scriptName, nil, _targetDid!, _appDid!, String.self)))
        }())
    }
    
    public func test04Update() {
        registerScriptUpdate(UPDATE_NAME)
        callScriptUpdate(UPDATE_NAME)
    }

    private func registerScriptUpdate(_ scriptName: String) {
        XCTAssertNoThrow(try { [self] in
            let filter = ["author" : "$params.author"]
            let set = ["author" : "$params.author", "content" : "$params.content"]
            let update = ["$set" : set]
            let options = ["bypass_document_validation" : false, "upsert" :true]
            _ = try await(_scriptingService!.registerScript(scriptName, UpdateExecutable(scriptName, COLLECTION_NAME, filter, update, options), false, false))
        }())
    }
    
    private func callScriptUpdate(_ scriptName: String) {
        XCTAssertNoThrow(try { [self] in
            let params = ["author" : "John", "content" : "message"]
            let result = try await(_scriptRunner!.callScript(scriptName, params, _targetDid!, _appDid!, JSON.self))
            XCTAssertNotNil(result)
            XCTAssert(result[scriptName] != nil)
            XCTAssert(result[scriptName]["upserted_id"] != nil)
        }())
    }
    
    public func test05Delete() {
        registerScriptDelete(DELETE_NAME)
        callScriptDelete(DELETE_NAME)
    }
    
    private func registerScriptDelete(_ scriptName: String) {
        XCTAssertNoThrow(try { [self] in
            let filter = ["author" : "$params.author"]
            try await(_scriptingService!.registerScript(scriptName, DeleteExecutable(scriptName, COLLECTION_NAME, filter), false, false))
        }())
    }
   
    private func callScriptDelete(_ scriptName: String) {
        XCTAssertNoThrow(try { [self] in
            let params = ["author" : "John"]
            let result = try await(_scriptRunner!.callScript(scriptName, params, _targetDid!, _appDid!, JSON.self))
            XCTAssertNotNil(result)
            XCTAssert(result[scriptName] != nil)
            XCTAssert(result[scriptName]["deleted_count"] != nil)
        }())
    }

    private func registerScriptFileUpload(_ scriptName: String) {
        XCTAssertNoThrow(try { [self] in
            try await(_scriptingService!.registerScript(scriptName, FileUploadExecutable(scriptName).setOutput(true), false, false))
        }())
    }

//    private func callScriptFileUpload(_ scriptName: String, _ fileName: String) -> String {
//        do {
//            let result = try await(_scriptRunner!.callScript(scriptName, Executable.createRunFileParams(fileName), _targetDid!, _appDid!, JSON.self))
//            XCTAssertNotNil(result)
//            XCTAssert(result[scriptName] != nil)
//            XCTAssert(result[scriptName]["transaction_id"] != nil)
//            return result[scriptName]["transaction_id"].string!
//            
//        } catch {
//            print(error)
//        }
//
//    }
    
    private func uploadFileByTransActionId(_ transactionId: String) {
        
    }
    
    public func test08FileProperties() {
        registerScriptFileProperties(FILE_PROPERTIES_NAME)
        callScriptFileProperties(FILE_PROPERTIES_NAME, fileName)
    }
    
    public func registerScriptFileProperties(_ scriptName: String) {
        XCTAssertNoThrow(try { [self] in
            _scriptingService?.registerScript(scriptName, FilePropertiesExecutable(scriptName).setOutput(true), false, false)
        }())
    }

    public func callScriptFileProperties(_ scriptName: String, _ fileName: String) {
        XCTAssertNoThrow(try { [self] in
            let result = try await(_scriptRunner!.callScript(scriptName, Executable.createRunFileParams(fileName), _targetDid!, _appDid!, JSON.self))
            XCTAssertNotNil(result)
            XCTAssert(result[scriptName] != nil)
            XCTAssert(((result[scriptName].string?.contains("size")) != nil))
        }())
    }
    
    public func test09FileHash() {
        registerScriptFileHash(FILE_HASH_NAME)
        callScriptFileHash(FILE_HASH_NAME, fileName)
    }

    private func registerScriptFileHash(_ scriptName: String) {
        XCTAssertNoThrow(try { [self] in
            _scriptingService?.registerScript(scriptName, FileHashExecutable(scriptName).setOutput(true), false, false)
        }())
    }
    
    private func callScriptFileHash(_ scriptName: String, _ fileName: String) {
        XCTAssertNoThrow(try { [self] in
            let result = try await(_scriptRunner!.callScript(scriptName, Executable.createRunFileParams(fileName), _targetDid!, _appDid!, JSON.self))
            XCTAssertNotNil(result)
            XCTAssert(result[scriptName] != nil)
            XCTAssert(((result[scriptName].string?.contains("SHA256")) != nil))
        }())
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

    override func tearDownWithError() throws {

    }
}
