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

import Foundation
import ElastosHiveSDK

class ScriptOwner {
    private var sdkContext: SdkContext?
    private var scriptingService: ScriptingProtocol?
    private var databaseService: DatabaseProtocol?
    
    private var ownerDid: String?
    private var callDid: String?
    private var appDid: String?

    public init(_ sdkContext: SdkContext) throws {
        self.sdkContext = sdkContext
        self.scriptingService = try self.sdkContext?.newVault().scriptingService
        self.databaseService = try self.sdkContext?.newVault().databaseService
        self.ownerDid = self.sdkContext?.ownerDid
        self.callDid = self.sdkContext?.callerDid
        self.appDid = self.sdkContext?.appId
    }
    
    public func setScript() -> Promise<Bool> {
        
        let createGroup: Promise<Bool> = self.databaseService!.createCollection(ScriptConst.COLLECTION_GROUP, nil)
        let createMessage: Promise<Bool> = self.databaseService!.createCollection(ScriptConst.COLLECTION_GROUP_MESSAGE, nil)

        let docNode = ["collection" : ScriptConst.COLLECTION_GROUP_MESSAGE, "did" : self.callDid!]
        let addPermission: Promise<InsertDocResponse> = self.databaseService!.insertOne(ScriptConst.COLLECTION_GROUP, docNode, InsertOneOptions(false))
        
        let filter: Dictionary<String, String> = ["collection": ScriptConst.COLLECTION_GROUP_MESSAGE,
                                                  "did": "$caller_did"]
        let condition = Condition("verify_user_permission", "queryHasResults", ScriptFindBody(ScriptConst.COLLECTION_GROUP, filter))
        let body = ScriptInsertExecutableBody(ScriptConst.COLLECTION_GROUP_MESSAGE,
            ["author" : "$params.author", "content" : "$params.content"],
            ["bypass_document_validation" : false, "ordered" : true])
        let executable = Executable.createInsertExecutable(ScriptConst.SCRIPT_NAME, body)
        let setScript: Promise<Bool> = self.scriptingService!.registerScript(ScriptConst.SCRIPT_NAME, condition, executable, false, false)
        
        return when(fulfilled: createGroup, createMessage).then { (r1, r2) -> Promise<InsertDocResponse> in
            return addPermission
        }.then { response -> Promise<Bool> in
            return setScript
        }
    }
    
}
