/*
* Copyright (c) 2019 Elastos Foundation
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

public enum ScriptingType {
    case UPLOAD
    case DOWNLOAD
    case PROPERTIES
}

public protocol ScriptingProtocol {
    
    /// Lets the vault owner register a script on his vault for a given app.
    /// The script is built on the client side, then serialized and stored on the hive back-end.
    /// Later on, anyone, including the vault owner or external users,
    ///  can use Scripting.call() to execute one of those scripts and get results/data.
    func registerScript(_ name: String, _ executable: Executable, _ allowAnonymousUser: Bool, _ allowAnonymousApp: Bool) -> Promise<Bool>
    
    func registerScript(_ name: String, _ condition: Condition, _ executable: Executable, _ allowAnonymousUser: Bool, _ allowAnonymousApp: Bool) -> Promise<Bool>

    /// Executes a previously registered server side script using Scripting.setScript(). Vault owner or external users are
    /// - Parameters:
    ///   - name: the call's script name
    ///   - resultType: String、 Data、 JSON、 Dictionry<String, Any>
    func callScript<T>(_ name: String, _ params: [String: Any]?, _ appDid: String?, _ resultType: T.Type) -> Promise<T>
    
    /// Run a script to upload a file NOTE:
    /// The upload works a bit differently compared to other types of executable queries
    /// because there are two steps to this executable.
    ///  First, register a script on the vault, then you call this api to actually upload the file
    /// - Parameters:
    ///   - transactionId: transactionId
    func uploadFile(_ transactionId: String) -> Promise<FileWriter>
    
    /// Run a script to download a file NOTE:
    /// The download works a bit differently compared to other types of executable queries
    /// because there are two steps to this executable.
    /// First, register a script on the vault, then you call this api to actually upload the file
    /// - Parameter transactionId: transactionId
    func downloadFile(_ transactionId: String) -> Promise<FileReader>
}
