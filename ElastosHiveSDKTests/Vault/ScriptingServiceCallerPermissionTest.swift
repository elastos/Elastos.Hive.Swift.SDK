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
import XCTest

private let COLLECTION_GROUP: String = "st_group"
private let COLLECTION_GROUP_MESSAGE: String = "st_group_message"
private let SCRIPT_NAME: String = "st_group_message"

class ScriptingServiceCallerPermissionTest: XCTestCase {
    private var scriptingService: ScriptingProtocol?
    private var scriptRunner: ScriptRunner?
    private var databaseService: DatabaseProtocol?
    
    private var callDid: String?
    private var appId: String?
    private var ownerDid: String?

    override func setUpWithError() throws {
//        try XCTSkipIf(true)
        Log.setLevel(.Debug)
        let testData = TestData.shared
        
        self.scriptingService = try testData.newVault().scriptingService
        self.scriptRunner = try testData.newCallerScriptRunner()
        self.databaseService = try testData.newVault().databaseService
        self.appId = testData.appId
        self.ownerDid = testData.ownerDid
        self.callDid = testData.callerDid
    }
    
    func testCallerGroupPermission() {
        initForCaller()
        setPermissionForCaller()
        registerScriptForCaller()
        runScriptWithGroupPermission()
        removePermissionForCaller()
        runScriptWithoutGroupPermission()
        uninitForCaller()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func initForCaller() {
        let lock = XCTestExpectation(description: "wait for create collection.")
        self.databaseService!.createCollection(COLLECTION_GROUP, nil).then({ isSuccess -> Promise<Bool> in
            return self.databaseService!.createCollection(COLLECTION_GROUP_MESSAGE, nil)
        }).done { success in
            XCTAssertTrue(success)
            lock.fulfill()
        }.catch { _ in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func setPermissionForCaller() {
        //add group named COLLECTION_GROUP_MESSAGE and add caller did into it,
        //  then caller will get the permission
        //  to access collection COLLECTION_GROUP_MESSAGE
        let lock = XCTestExpectation(description: "wait for create collection.")
        let docNode: Dictionary<String, String> = ["collection" : COLLECTION_GROUP_MESSAGE,
                       "did" : self.callDid!]
        self.databaseService!.insertOne(COLLECTION_GROUP, docNode, InsertOneOptions(false)).done { (insert) in
            XCTAssertNotNil(insert)
            lock.fulfill()
        }.catch { _ in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }

    
    func registerScriptForCaller() {
        let lock = XCTestExpectation(description: "wait for create collection.")
        let filter: Dictionary<String, String> = ["collection": COLLECTION_GROUP_MESSAGE,
                                                  "did": "$callScripter_did"]
        let condition = Condition("verify_user_permission", "queryHasResults", ScriptFindBody(COLLECTION_GROUP, filter))
        let body = ScriptInsertExecutableBody(COLLECTION_GROUP_MESSAGE,
                                              ["author" : "$params.author", "content" : "$params.content"],
                                              ["bypass_document_validation" : false, "ordered" : true])
        let executable = Executable.createInsertExecutable(SCRIPT_NAME, body)
        self.scriptingService!.registerScript(SCRIPT_NAME, condition, executable, false, false).done { success in
            XCTAssertTrue(success)
            lock.fulfill()
        }.catch { _ in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
        
    func runScriptWithGroupPermission() {
        let lock = XCTestExpectation(description: "wait for create collection.")
        self.scriptRunner!.callScript(SCRIPT_NAME, ["author" : "John", "content" : "message"], self.ownerDid, self.appId, JSON.self).done { json in
            XCTAssertNotNil(json)
            lock.fulfill()
        }.catch { error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func removePermissionForCaller() {
        let lock = XCTestExpectation(description: "wait for create collection.")
        let filter: Dictionary<String, String> = [
            "collection" : COLLECTION_GROUP_MESSAGE,
            "did" : self.callDid!
        ]
        self.databaseService!.deleteOne(COLLECTION_GROUP, filter, options: DeleteOptions()).done { delete in
           XCTAssertNotNil(delete)
            lock.fulfill()
        }.catch { _ in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func runScriptWithoutGroupPermission() {
        let lock = XCTestExpectation(description: "wait for create collection.")
        self.scriptRunner!.callScript(SCRIPT_NAME, ["author" : "John", "content" : "message"], self.ownerDid, self.appId, JSON.self).done { json in
            XCTAssertNotNil(json)
            lock.fulfill()
        }.catch { _ in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func uninitForCaller() {
        let lock = XCTestExpectation(description: "wait for create collection.")
        _ = databaseService?.deleteCollection(COLLECTION_GROUP_MESSAGE).then({ [self] success -> Promise<Bool> in
            return (databaseService?.deleteCollection(COLLECTION_GROUP))!
        }).done({ success in
            XCTAssertTrue(success)
            lock.fulfill()
        }).catch({ _ in
            XCTFail()
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 100.0)
    }
}
