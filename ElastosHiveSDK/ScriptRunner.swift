/*
 * Copyright (c) 2021 Elastos Foundation
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

//public class ScriptRunner: ServiceEndpoint, ScriptingInvocationProtocol {


//    private var scriptingServiceRender: ScriptingServiceRender?
//    
//    public override init(_ context: AppContext, _ providerAddress: String) throws {
//        try super.init(context, providerAddress)
//        self.scriptingServiceRender = ScriptingServiceRender(self)
//    }
//    
//    /// Set-up a context for get more detailed information for backup sExecutes a previously registered server side script using Scripting.setScript(). Vault owner or external users are allowed to call scripts on someone's vault.
//    /// - parameters:
//    ///    - name: The call's script name
//    ///    - resultType: String, JSON
//    /// - returns:  Result for specific script type
//    public func callScript<T>(_ name: String, _ params: [String : Any]?, _ targetDid: String?, _ targetAppDid: String?, _ resultType: T.Type) -> Promise<T> {
//        return self.scriptingServiceRender!.callScript(name, params, targetDid, targetAppDid, resultType)
//    }
//    
//    /// Executes a previously registered server side script with a direct URL where the values can be passed as part of the query.Vault owner or external users are allowed to call scripts on someone's vault.
//    /// - parameters:
//    ///    - name: The call's script name
//    ///    - resultType: String, JSON
//    /// - returns:  Result for specific script type
//    public func callScriptUrl<T>(_ name: String, _ params: String?, _ targetDid: String?, _ targetAppDid: String?, _ resultType: T.Type) -> Promise<T> {
//        return self.scriptingServiceRender!.callScriptUrl(name, params, targetDid, targetAppDid, resultType)
//    }
//    
//    /// Run a script to upload a file NOTE: The upload works a bit differently compared to other types of executable queries because there are two steps to this executable. First, register a script on the vault, then you call this api to actually upload the file
//    /// - parameters:
//    ///    - transactionId: Transaction id
//    /// - returns: FileReader
//    public func uploadFile<T>(_ transactionId: String, _ resultType: T.Type) -> Promise<T> {
//        return self.scriptingServiceRender!.uploadFile(transactionId, resultType)
//
//    }
//    
//    public func downloadFile<T>(_ transactionId: String, _ resultType: T.Type) -> Promise<T> {
//        return self.scriptingServiceRender!.downloadFile(transactionId, resultType)
//
//    }

//}
