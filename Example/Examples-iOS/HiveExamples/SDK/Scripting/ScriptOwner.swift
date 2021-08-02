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

class ScriptOwner {
    private var sdkContext: SdkContext?
    private var scriptingService: ScriptingService?
    private var databaseService: DatabaseService?

    private var callDid: String?

    public init(_ sdkContext: SdkContext) throws {
        self.sdkContext = sdkContext
        self.scriptingService = sdkContext.newVault().scriptingService
        self.databaseService = try sdkContext.newVault().databaseService
        self.callDid = self.sdkContext?.callerDid
    }
    
    public func cleanTwoCollections() -> Promise<Void> {
        let promiseA = self.databaseService!.deleteCollection(ScriptConst.COLLECTION_GROUP)
        let promiseB = self.databaseService!.deleteCollection(ScriptConst.COLLECTION_GROUP_MESSAGE)
        return Promise.

}


    private CompletableFuture<Void> cleanTwoCollections() {
        return databaseService.deleteCollection(ScriptConst.COLLECTION_GROUP)
                .thenCompose(s -> databaseService.deleteCollection(ScriptConst.COLLECTION_GROUP_MESSAGE));
    }

    private CompletableFuture<Void> createTwoCollections() {
        return databaseService.createCollection(ScriptConst.COLLECTION_GROUP)
                .thenCompose(s->databaseService.createCollection(ScriptConst.COLLECTION_GROUP_MESSAGE));
    }

    private CompletableFuture<InsertResult> addPermission2Caller() {
        // The document to save the permission of the user DID.
        ObjectNode conditionDoc = JsonNodeFactory.instance.objectNode();
        conditionDoc.put("collection", ScriptConst.COLLECTION_GROUP_MESSAGE);
        conditionDoc.put("did", callDid);
        // Insert persmission to COLLECTION_GROUP
        return databaseService.insertOne(
                ScriptConst.COLLECTION_GROUP,
                conditionDoc,
                new InsertOptions().bypassDocumentValidation(false));
    }

    private CompletableFuture<Void> doSetScript() {
        // The condition to restrict the user DID.
        ObjectNode filter = JsonNodeFactory.instance.objectNode();
        filter.put("collection",ScriptConst.COLLECTION_GROUP_MESSAGE);
        filter.put("did","$caller_did");
        // The message is for inserting to the COLLECTION_GROUP_MESSAGE.
        ObjectNode msgDoc = JsonNodeFactory.instance.objectNode();
        msgDoc.put("author", "$params.author");
        msgDoc.put("content", "$params.content");
        ObjectNode options = JsonNodeFactory.instance.objectNode();
        options.put("bypass_document_validation", false);
        options.put("ordered", true);
        // register the script for caller to insert message to COLLECTION_GROUP_MESSAGE
        return scriptingService.registerScript(ScriptConst.SCRIPT_NAME,
                new QueryHasResultCondition("verify_user_permission", ScriptConst.COLLECTION_GROUP, filter),
                new InsertExecutable(ScriptConst.SCRIPT_NAME, ScriptConst.COLLECTION_GROUP_MESSAGE, msgDoc, options),
                false, false);
    }

    public CompletableFuture<Void> setScript() {
        return cleanTwoCollections()
                .thenCompose(s->createTwoCollections())
                .thenCompose(s->addPermission2Caller())
                .thenCompose(s->doSetScript());
    }
}
