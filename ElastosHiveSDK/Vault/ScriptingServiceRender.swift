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

public class ScriptingServiceRender: ScriptingService {
    private var _controller: ScriptingController

    public init(_ serviceEndpoint: ServiceEndpoint) {
        _controller = ScriptingController(serviceEndpoint)
    }
    
    /// Lets the vault owner register a script on his vault for a given application.
    /// The script is built on the client-side, then serialized and stored on the
    /// vault service. Later on, the vault owner or external users can invoke the script
    /// to execute one of those scripts and get results or data.
    /// - Parameters:
    ///   - name: the name of script to register
    ///   - executable: the executable body of the script with preset routines
    /// - Returns: Void
    public func registerScript(_ name: String, _ executable: Executable) -> Promise<Void> {
        return registerScript(name, nil, executable, false, false)
    }
    
    /// Lets the vault owner register a script on his vault for a given application.
    /// The script is built on the client-side, then serialized and stored on the
    /// vault service. Later on, the vault owner or external users can invoke the script
    /// to execute one of those scripts and get results or data.
    /// - Parameters:
    ///   - name: the name of script to register
    ///   - condition: the condition on which the script could be executed.
    ///   - executable: the executable body of the script with preset routines
    /// - Returns: Void
    public func registerScript(_ name: String, _ condition: Condition, _ executable: Executable) -> Promise<Void> {
        return registerScript(name, condition, executable, false, false)
    }
    
    /// Lets the vault owner register a script on his vault for a given application.
    /// The script is built on the client-side, then serialized and stored on the
    /// vault service. Later on, the vault owner or external users can invoke the script
    /// to execute one of those scripts and get results or data.
    /// - Parameters:
    ///   - name: the name of script to register
    ///   - executable: the executable body of the script with preset routines
    ///   - allowAnonymousUser: whether allows anonymous user.
    ///   - allowAnonymousApp: whether allows anonymous application.
    /// - Returns: Void
    public func registerScript(_ name: String, _ executable: Executable, _ allowAnonymousUser: Bool, _ allowAnonymousApp: Bool) -> Promise<Void> {
        return registerScript(name, nil, executable, allowAnonymousUser, allowAnonymousApp)
    }
    
    /// Lets the vault owner register a script on his vault for a given application.
    /// The script is built on the client-side, then serialized and stored on the
    /// vault service. Later on, the vault owner or external users can invoke the script
    /// to execute one of those scripts and get results or data.
    /// - Parameters:
    ///   - name: the name of script to register
    ///   - condition: the condition on which the script could be executed.
    ///   - executable: the executable body of the script with preset routines
    ///   - allowAnonymousUser: whether allows anonymous user.
    ///   - allowAnonymousApp: whether allows anonymous application.
    /// - Returns: Void
    public func registerScript(_ name: String, _ condition: Condition?, _ executable: Executable, _ allowAnonymousUser: Bool, _ allowAnonymousApp: Bool) -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.registerScript(name, condition, executable, allowAnonymousUser, allowAnonymousApp)
        }
    }
    
    /// Let the vault owner unregister a script when the script become useless to applications.
    /// - parameters:
    ///   - name: name the name of script to unregister.
    /// - returns: void
    public func unregisterScript(_ name: String) -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.unregisterScript(name)
        }
    }
    
    /// Invoke the execution of a specified script registered previously by the vault
    /// owner, where the script is defined with certain preset routines.
    /// It's the general invocation method for external users to call.
    /// - Parameters:
    ///   - name: The name of script to invoke.
    ///   - params: The parameters as input to the invocation.
    ///   - targetDid: The script owner's user did. Skipped when owner calls.
    ///   - targetAppDid: The script owner's application did. Skipped when owner calls.
    ///   - resultType: String, Dictionry, Data.
    /// - Returns: T
    public func callScript<T>(_ name: String, _ params: [String : Any]?, _ targetDid: String, _ targetAppDid: String, _ resultType: T.Type) -> Promise<T> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.callScript(name, params, targetDid, targetAppDid, resultType)
        }
    }

    /// Executes a previously registered server side script with a direct URL where the values can be passed as part of the query. Vault owner or external users are allowed to call scripts on someone's vault.
    ///
    /// - parameters:
    ///   - name: The call's script name
    ///   - params: The parameters for the script.
    ///   - targetDid: The script owner's user did.
    ///   - targetAppDid: The script owner's application did.
    ///   - resultType: Objects
    /// - returns: Result for specific script type
    public func callScriptUrl<T>(_ name: String, _ params: String, _ targetDid: String, _ targetAppDid: String, _ resultType: T.Type) -> Promise<T> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.callScriptUrl(name, params, targetDid, targetAppDid, resultType)
        }
    }
    
    /// Invoke the execution of the script to upload a file in the streaming mode. The upload works a bit differently from other executable queries because there are two steps to this executable. First, register a script on the vault, then you call this API actually to upload the file
    /// - parameters:
    ///    - transactionId: The streaming identifier to the upload process
    /// - returns:FileWriter
    public func uploadFile(_ transactionId: String) -> Promise<FileWriter> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.uploadFile(transactionId)
        }
    }

    /// Invoke the execution of the script to download a file in the streaming mode. The upload works a bit differently from other executable queries because there are two steps to this executable. First, register a script on the vault, then you call this API actually to download the file
    /// - parameters:
    ///    - transactionId: The streaming identifier to the upload process
    /// - returns: FileReader
    public func downloadFile(_ transactionId: String) -> Promise<FileReader> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.downloadFile(transactionId)
        }
    }
}
