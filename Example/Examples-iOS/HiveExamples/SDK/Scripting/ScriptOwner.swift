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
import SwiftyJSON
import AwaitKit
import PromiseKit

class ScriptOwner {
    private var sdkContext: SdkContext?
    private var scriptingService: ScriptingService?
    private var databaseService: DatabaseService?

    private var callDid: String?

    public init(_ sdkContext: SdkContext) throws {
        self.sdkContext = sdkContext
        self.scriptingService = sdkContext.newVault().scriptingService
        self.databaseService = sdkContext.newVault().databaseService
        self.callDid = self.sdkContext?.callerDid
    }
    
    public func cleanTwoCollections() -> Promise<Void> {
        return self.databaseService!.deleteCollection(ScriptConst.COLLECTION_GROUP).then { () -> Promise<Void> in
            return self.databaseService!.deleteCollection(ScriptConst.COLLECTION_GROUP_MESSAGE)
        }
    }
    
    public func createTwoCollections() -> Promise<Void> {
        return self.databaseService!.createCollection(ScriptConst.COLLECTION_GROUP).then { () -> Promise<Void> in
            return self.databaseService!.createCollection(ScriptConst.COLLECTION_GROUP_MESSAGE)
        }
    }
    
    private func addPermission2Caller() -> Promise<InsertResult> {
        let conditionDoc: [String : Any] = ["collection" : ScriptConst.COLLECTION_GROUP_MESSAGE, "did" : self.callDid!]
        return self.databaseService!.insertOne(ScriptConst.COLLECTION_GROUP, conditionDoc , InsertOptions().bypassDocumentValidation(false))
    }
    
    private func doSetScript() -> Promise<Void> {
        // The condition to restrict the user DID.
        let filter = ["collection" : ScriptConst.COLLECTION_GROUP_MESSAGE, "did" : "$caller_did"]
        // The message is for inserting to the COLLECTION_GROUP_MESSAGE.
        let msgDoc = ["author" : "$params.author", "content" : "$params.content"]
        let options = ["bypass_document_validation" : false, "ordered" : true]
        // register the script for caller to insert message to COLLECTION_GROUP_MESSAGE
        return self.scriptingService!.registerScript(ScriptConst.SCRIPT_NAME,
                                                 QueryHasResultCondition("verify_user_permission", ScriptConst.COLLECTION_GROUP, filter),
                                                 InsertExecutable(ScriptConst.SCRIPT_NAME, ScriptConst.COLLECTION_GROUP_MESSAGE, msgDoc, options))
        
    }
    
    public func setScript() -> Promise<Void> {
        cleanTwoCollections().then { _ -> Promise<Void> in
            return self.createTwoCollections()
        }.then { _ -> Promise<InsertResult> in
            return self.addPermission2Caller()
        }.then { _ -> Promise<Void> in
            return self.doSetScript()
        }
    }

}
