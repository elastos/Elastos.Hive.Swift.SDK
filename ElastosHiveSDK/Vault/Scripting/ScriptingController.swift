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
import SwiftyJSON

/// The wrapper class to access the scripting APIs of the hive node.
public class ScriptingController {
    private var _connectionManager: ConnectionManager?
    
    /// Create by the ServiceEndpoint.
    /// - Parameter serviceEndpoint: The ServiceEndpoint.
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _connectionManager = serviceEndpoint.connectionManager!
    }
    
    /// Register a script on the hive node.
    /// - Parameters:
    ///   - name: The name of the script.
    ///   - condition: The condition of the script. To run the script normally, the condition must be matched.
    ///   - executable: The executable represents an executed action.
    ///   - allowAnonymousUser: If allow the anonymous user to run the script.
    ///   - allowAnonymousApp: If allow the anonymous application to run the script.
    /// - Throws: HiveError The error comes from the hive node.
    public func registerScript(_ name: String, _ condition: Condition?, _ executable: Executable?, _ allowAnonymousUser: Bool?, _ allowAnonymousApp: Bool?) throws {
        let params = RegScriptParams()
            .setExecutable(executable)
            .setAllowAnonymousUser(allowAnonymousUser)
            .setAllowAnonymousApp(allowAnonymousApp)
            .setCondition(condition)
        _ = try _connectionManager?.registerScript(name, params).execute(RegScriptResult.self)
    }
    
    /// Run the registered script. The runner is not the owner of the script normally.
    /// - Parameters:
    ///   - name: The name of the script.
    ///   - params: The parameters to run the script.
    ///   - targetDid: The owner of the script.
    ///   - targetAppDid: The application DID owns the script.
    ///   - resultType: Supported type: String, Dictionary, Data.
    /// - Throws: HiveError
    /// - Returns: <T> Same as result type.
    public func callScript<T>(_ name: String, _ params: Dictionary<String, Any>?, _ targetDid: String?, _ targetAppDid: String?, _ resultType: T.Type) throws -> T {
        let context = Context().setTargetDid(targetDid).setTargetAppDid(targetAppDid)
        let runScriptParams = RunScriptParams().setContext(context).setParams(params)
        let response = try _connectionManager?.runScript(name, runScriptParams).execute()
        return try handleResult(JSON(response?._json as Any), resultType)
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
    public func callScriptUrl<T>(_ name: String, _ params: String, _ targetDid: String, _ targetAppDid: String, _ resultType: T.Type) throws -> T {
        let response = try _connectionManager?.runScriptUrl(name, targetDid, targetAppDid, params).execute()
        return try handleResult(JSON(response?._json as Any), resultType)
    }

    /// Invoke the execution of the script to upload a file in the streaming mode. The upload works a bit differently from other executable queries because there are two steps to this executable. First, register a script on the vault, then you call this API actually to upload the file
    /// - parameters:
    ///    - transactionId: The streaming identifier to the upload process
    /// - returns:FileWriter
    public func uploadFile(_ transactionId: String) throws -> FileWriter {
        let url = "\(_connectionManager!.baseURL)\(ScriptingAPI.API_SCRIPT_UPLOAD)/\(transactionId)"
        return FileWriter(URL(string: url)!, _connectionManager!)
    }
    
    /// Invoke the execution of the script to download a file in the streaming mode. The upload works a bit differently from other executable queries because there are two steps to this executable. First, register a script on the vault, then you call this API actually to download the file
    /// - parameters:
    ///    - transactionId: The streaming identifier to the upload process
    /// - returns: FileReader
    public func downloadFile(_ transactionId: String) throws -> FileReader {
        let url = "\(_connectionManager!.baseURL)\(ScriptingAPI.API_SCRIPT_DOWNLOAD)/\(transactionId)"
        return try FileReader(URL(string: url)!, _connectionManager!, .get)
    }

    public func downloadFileByHiveUrl(_ hiveUrl: String) throws -> FileReader {
        let info = try HiveUrlInfo(hiveUrl)
        let result = try callScript(info.scriptName, info.params,
                                   info.targetDid, info.targetAppDid, JSON.self)
        let tx = searchForEntity(result)
        guard tx != nil else {
            throw HiveError.InvalidParameterException("Transaction id is nil.")
        }
        return try downloadFile(tx)
    }
    
    func searchForEntity(_ p: JSON) -> String {
        var transaction_id = ""
        p.forEach { k, v in
            v.forEach { k, v in
                if k == "transaction_id" {
                    transaction_id = v.stringValue
                }
            }
        }
        return transaction_id
    }
    
    /// Unregister the script.
    /// - Parameter name: The name of the script.
    public func unregisterScript(_ name: String) throws {
        _ = try _connectionManager?.unregisterScript(name).execute()
    }
    
    private func handleResult<T>(_ json: JSON, _ resultType: T.Type) throws -> T {
        // The String type
        if resultType.self == String.self {
            let dic = json.dictionaryObject as Any
            let data = try JSONSerialization.data(withJSONObject: dic, options: [])
            let str = String(data: data, encoding: String.Encoding.utf8)
            return str as! T
        } else if resultType.self == Dictionary<String, Any>.self {// The Dictionary type
            let dic = json.dictionaryObject
            return dic as! T
        } else if resultType.self == JSON.self { // The JSON type
            return JSON(json) as! T
        } else { // the Data type
            let result = json.dictionaryObject as Any
            let data = try JSONSerialization.data(withJSONObject: result, options: [])
            return data as! T
        }
    }
}
