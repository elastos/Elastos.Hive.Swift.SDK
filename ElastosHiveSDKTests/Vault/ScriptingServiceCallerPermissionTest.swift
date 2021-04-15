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
    private var scriptingServiceCaller: ScriptingProtocol?
    private var databaseService: DatabaseProtocol?
    
    private var callDid: String?
    private var appId: String?

    override func setUpWithError() throws {
        let testData = TestData.shared
        
        self.scriptingService = testData.newVault().scriptingService
        self.scriptingServiceCaller = testData.newVault4Scripting().scriptingService
        self.databaseService = testData.newVault().databaseService
        self.appId = testData.appId

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func initForCaller() -> Promise<Bool> {
        return self.databaseService!.createCollection(COLLECTION_GROUP, nil).then({ isSuccess -> Promise<Bool> in
            return self.databaseService!.createCollection(COLLECTION_GROUP_MESSAGE, nil)
        })
    }
    
    func setPermissionForCaller() -> Promise<InsertDocResponse> {
        //add group named COLLECTION_GROUP_MESSAGE and add caller did into it,
        //  then caller will get the permission
        //  to access collection COLLECTION_GROUP_MESSAGE
        let docNode: Dictionary<String, String> = ["collection" : COLLECTION_GROUP_MESSAGE,
                       "did" : self.callDid!]
        return self.databaseService!.insertOne(COLLECTION_GROUP, docNode, InsertOneOptions(false))
    }

    
    func registerScriptForCaller() -> Promise<Bool> {
        
        let filter: Dictionary<String, String> = ["collection": COLLECTION_GROUP_MESSAGE,
                                                  "did": "$callScripter_did"]
        let condition = Condition("verify_user_permission", "queryHasResults", ScriptFindBody(COLLECTION_GROUP, filter))
        let body = ScriptInsertExecutableBody(COLLECTION_GROUP_MESSAGE,
                                              ["author" : "$params.author", "content" : "$params.content"],
                                              ["bypass_document_validation" : false, "ordered" : true])
        let executable = Executable.createInsertExecutable(SCRIPT_NAME, body)
        return self.scriptingService!.registerScript(SCRIPT_NAME, condition, executable, false, false)
    }
        
    func runScriptWithGroupPermission() -> Promise<JSON> {
        return self.scriptingServiceCaller!.callScript(SCRIPT_NAME, ["author" : "John", "content" : "message"], self.appId, JSON.self)
    }
    
    func removePermissionForCaller() -> Promise<DeleteResult> {
        let filter: Dictionary<String, String> = [
            "collection" : COLLECTION_GROUP_MESSAGE,
            "did" : self.callDid!
        ]
        return self.databaseService!.deleteOne(COLLECTION_GROUP, filter, options: DeleteOptions())
    }
    
    func runScriptWithoutGroupPermission() -> Promise<JSON> {
        return self.scriptingServiceCaller!.callScript(SCRIPT_NAME, ["author" : "John", "content" : "message"], self.appId, JSON.self)
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
