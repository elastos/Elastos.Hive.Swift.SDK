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

/**
* Vault provides the scripting service to general users to execute a preset
* script by the vault owner.
*/
public protocol ScriptingInvocationService {
    /// Invoke the execution of a specified script registered previously by the vault owner, where the script is defined with certain preset routines. It's the general invocation method for external users to call.
    /// - parameters:
    ///    - name: The name of script to invoke.
    ///    - params: The parameters as input to the invocation.
    ///    - targetDid: The script owner's user did. Skipped when owner calls.
    ///    - targetAppDid: The script owner's application did. Skipped when owner calls.
    ///    - resultType: String, byte[], FileReader
    ///    - T: String, byte[], FileReader
    /// - returns:  String, Data, JSON, FileReader
    func callScript<T>(_ name: String, _ params: [String : Any]?, _ targetDid: String, _ targetAppDid: String, _ resultType: T.Type) -> Promise<T>;
    
    /// Invoke the execution of the script to upload a file in the streaming mode. The upload works a bit differently from other executable queries because there are two steps to this executable. First, register a script on the vault, then you call this API actually to upload the file
    /// - parameters:
    ///    - transactionId: The streaming identifier to the upload process
    /// - returns:FileWriter
    func uploadFile(_ transactionId: String) -> Promise<FileWriter>;

    /// Invoke the execution of the script to download a file in the streaming mode. The upload works a bit differently from other executable queries because there are two steps to this executable. First, register a script on the vault, then you call this API actually to download the file
    /// - parameters:
    ///    - transactionId: The streaming identifier to the upload process
    /// - returns: FileReader
    func downloadFile(_ transactionId: String) -> Promise<FileReader>;
}
