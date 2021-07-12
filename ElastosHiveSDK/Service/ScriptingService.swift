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
 * Vault provides the scripting service to vault owners to register executable
 * script and make invocation as well. The executable script registered by the
 * vault owner mainly serves external users to invoke for executing the preset
 * routine defined in the script.
 */
public protocol ScriptingService: ScriptingInvocationService {
    func registerScript(_ name: String, _ executable: Executable) -> Promise<Void>
    func registerScript(_ name: String, _ condition: Condition, _ executable: Executable) -> Promise<Void>
    
    /// Lets the vault owner register a script on his vault for a given application. The script is built on the client-side, then serialized and stored on the vault service. Later on, the vault owner or external users can invoke the script to execute one of those scripts and get results or data.
    /// - parameters:
    ///   - name: name the name of script to register
    ///   - executable: the executable body of the script with preset routines
    ///   - allowAnonymousUser: whether allows anonymous user.
    ///   - allowAnonymousApp: whether allows anonymous application.
    /// - returns: void
    func registerScript(_ name: String, _ executable: Executable, _ allowAnonymousUser: Bool, _ allowAnonymousApp: Bool) -> Promise<Void>

    
    /// Lets the vault owner register a script on his vault for a given application. The script is built on the client-side, then serialized and stored on the vault service. Later on, the vault owner or external users can invoke the script to execute one of those scripts and get results or data.
    /// - parameters:
    ///   - name: name the name of script to register
    ///   - condition: the condition on which the script could be executed.
    ///   - executable: the executable body of the script with preset routines
    ///   - allowAnonymousUser: whether allows anonymous user.
    ///   - allowAnonymousApp: whether allows anonymous application.
    /// - returns: void
    func registerScript(_ name: String, _ condition: Condition, _ executable: Executable, _ allowAnonymousUser: Bool, _ allowAnonymousApp: Bool) -> Promise<Void>
    
    /// Let the vault owner unregister a script when the script become useless to applications.
    /// - parameters:
    ///   - name: name the name of script to unregister.
    ///   - target: the path to the target file or folder
    /// - returns: void
    func unregisterScript(_ name: String) -> Promise<Void>
}
