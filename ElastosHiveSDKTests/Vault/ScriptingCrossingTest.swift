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

class ScriptingCrossingTest: XCTestCase {
    private var _collectionGroup: String = "st_group"
    private var _collectionGroupMessage: String = "st_group_message"
    private var _scriptName: String = "get_group_message"

    private var _scriptingService: ScriptingService?
    private var _scriptRunner: ScriptRunner?
    private var _databaseService: DatabaseService?

    private var _targetDid: String
    private var _callDid: String
    private var _appDid: String

    override func setUpWithError() throws {
        XCTAssertNoThrow({ [self] in
            let testData = TestData.shared()
            _scriptingService = testData.newVault().scriptingService
            _scriptRunner = testData.newCallerScriptRunner()
            _databaseService = testData.newVault().databaseService
            _targetDid = testData.userDid
            _appDid = testData.appId
            _callDid = testData.callerDid
        })
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
        XCTAssertNoThrow({ [self] in
            try await(_databaseService!.createCollection(_collectionGroup))
            try await(_databaseService!.createCollection(_collectionGroupMessage))
        })
    }
   
    private func set_permission_for_caller() {
        XCTAssertNoThrow({ [self] in
            let docNode = ["collection" : _collectionGroupMessage, "did" : _callDid]
            try await(_databaseService!.insertOne(_collectionGroup, docNode, InsertOptions().bypassDocumentValidation(false)))
        })
    }
    
    private func register_script_for_caller() {
        XCTAssertNoThrow({ [self] in
            let filter = ["collection" : _collectionGroupMessage, "did" : "$caller_did"]
            let doc = ["author" : "$params.author", "content" : "$params.content"]
            let options = ["bypass_document_validation" : false, "ordered" : true]
            try await( _scriptingService!.registerScript(_scriptName,
                                                         QueryHasResultCondition("verify_user_permission", _collectionGroup, filter),
                                                         InsertExecutable(_scriptName, _collectionGroupMessage, doc, options)))
        })
    }
    
    private func run_script_with_group_permission() {
        XCTAssertNoThrow({ [self] in
            let params = ["author" : "John", "content" : "message"]
            try await(_scriptRunner!.callScript(_scriptName, params, _targetDid, _appDid, JSON.self))
            // TODO
        })
    }
    
    private func remove_permission_for_caller() {
        XCTAssertNoThrow({ [self] in
            let filter = ["collection" : _collectionGroupMessage, "did" : _callDid]
            try await(_databaseService?.deleteOne(_collectionGroup, filter))
        })
    }
    
    public func run_script_without_group_permission() {
        XCTAssertNoThrow({ [self] in
            let params = ["author" : "John", "content" : "message"]
            try await(_scriptRunner!.callScript(_scriptName, params, _targetDid, _appDid, JSON.self)))
        })
    }
    
    public func uninit_for_caller() {
        XCTAssertNoThrow({ [self] in
            try await(_databaseService!.deleteCollection(_collectionGroupMessage))
            try await(_databaseService!.deleteCollection(_collectionGroup))
        })
    }
}

