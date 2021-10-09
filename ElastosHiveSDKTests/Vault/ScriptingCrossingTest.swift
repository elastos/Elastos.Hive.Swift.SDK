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
import SwiftyJSON


class ScriptingCrossingTest: XCTestCase {
    private let COLLECTION_GROUP: String = "st_group";
    private let COLLECTION_GROUP_MESSAGE: String = "st_group_message";
    private let SCRIPT_NAME: String = "get_group_message";

    private var _scriptingService: ScriptingService?
    private var _scriptRunner: ScriptRunner?
    private var _databaseService: DatabaseService?

    private var _targetDid: String!
    private var _callDid: String!
    private var _appDid: String!

    override func setUpWithError() throws {
        Log.setLevel(.Debug)
        XCTAssertNoThrow(try { [self] in
            let testData = TestData.shared()
            _scriptingService = try testData.newVault().scriptingService
            _scriptRunner = try testData.newCallerScriptRunner()
            _databaseService = try testData.newVault().databaseService
            _targetDid = testData.userDid
            _appDid = testData.appId
            _callDid = testData.callerDid
        }())
    }
    
    /**
     * This process shows how caller run script with/without group permission.
     */
    public func testCallerGroupPermission() {
        init_for_caller();
        set_permission_for_caller();
        register_script_for_caller();
        run_script_with_group_permission();//called by caller.
        remove_permission_for_caller();
        run_script_without_group_permission();//called by caller.
        uninit_for_caller();
    }
    
    private func init_for_caller() {
        XCTAssertNoThrow(try { [self] in
            try `await`(_databaseService!.createCollection(COLLECTION_GROUP))
            try `await`(_databaseService!.createCollection(COLLECTION_GROUP_MESSAGE))
        }())
    }
   
    private func set_permission_for_caller() {
        XCTAssertNoThrow(try { [self] in
            let docNode: [String: Any] = ["collection" : COLLECTION_GROUP_MESSAGE, "did" : _callDid]
            try `await`(_databaseService!.insertOne(COLLECTION_GROUP, docNode, InsertOptions().bypassDocumentValidation(false)))
        }())
    }
    
    private func register_script_for_caller() {
        XCTAssertNoThrow(try { [self] in
            let filter = ["collection" : COLLECTION_GROUP_MESSAGE, "did" : "$caller_did"]
            let doc = ["author" : "$params.author", "content" : "$params.content"]
            let options = ["bypass_document_validation" : false, "ordered" : true]
            try `await`( _scriptingService!.registerScript(SCRIPT_NAME,
                                                         QueryHasResultCondition("verify_user_permission", COLLECTION_GROUP, filter),
                                                         InsertExecutable(SCRIPT_NAME, COLLECTION_GROUP_MESSAGE, doc, options)))
        }())
    }
    
    private func run_script_with_group_permission() {
        XCTAssertNoThrow(try { [self] in
            let params = ["author" : "John", "content" : "message"]
            let result = try `await`(_scriptRunner!.callScript(SCRIPT_NAME, params, _targetDid, _appDid, JSON.self))
            XCTAssertNotNil(result)
            XCTAssertTrue(result[SCRIPT_NAME]["inserted_id"].string!.count > 0)
        }())
    }
    
    private func remove_permission_for_caller() {
        XCTAssertNoThrow(try { [self] in
            let filter = ["collection" : COLLECTION_GROUP_MESSAGE, "did" : _callDid]
            try `await`(_databaseService!.deleteOne(COLLECTION_GROUP, filter))
        }())
    }
    
    public func run_script_without_group_permission() {
        XCTAssertNoThrow(try { [self] in
            let params = ["author" : "John", "content" : "message"]
            try `await`(_scriptRunner!.callScript(SCRIPT_NAME, params, _targetDid, _appDid, JSON.self))
        }())
    }
    
    public func uninit_for_caller() {
        XCTAssertNoThrow(try { [self] in
            try `await`(_databaseService!.deleteCollection(COLLECTION_GROUP_MESSAGE))
            try `await`(_databaseService!.deleteCollection(COLLECTION_GROUP))
        }())
    }
}

