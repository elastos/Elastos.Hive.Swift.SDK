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

public class ScriptingController {
    private var _connectionManager: ConnectionManager?
    
    public init(_ connectionManager: ConnectionManager) {
        _connectionManager = connectionManager
    }
    
    public func registerScript(_ name: String, _ condition: Condition?, _ executable: Executable?, _ allowAnonymousUser: Bool?, _ allowAnonymousApp: Bool?) throws {
        let params = RegScriptParams()
            .setExecutable(executable)
            .setAllowAnonymousApp(allowAnonymousApp)
            .setCondition(condition)
        _ = try _connectionManager?.registerScript(name, params).execute()?.getString()
    }
    
    public func callScript<T>(_ name: String, _ params: Dictionary<String, String>?, _ targetDid: String?, _ targetAppDid: String?, _ resultType: T.Type) throws -> T {
        let context = Context().setTargetDid(targetDid).setTargetAppDid(targetAppDid)
        let runScriptParams = RunScriptParams().setContext(context).setParams(params)
        let json = try _connectionManager?.runScript(name, runScriptParams).execute()?.getString()
        return try handleResult(JSON(json as Any), resultType)
    }
    
    public func callScriptUrl<T>(_ name: String, _ params: String, _ targetDid: String, _ targetAppDid: String, _ resultType: T.Type) throws -> T {
        let json = try _connectionManager?.runScriptUrl(name, targetDid, targetAppDid, params).execute()
        return try handleResult(JSON(json as Any), resultType)
    }

    public func uploadFile(_ transactionId: String) throws -> FileWriter {
        let url = "\(_connectionManager!.baseURL)\(ScriptingAPI.API_SCRIPT_UPLOAD)/\(transactionId)"
        return FileWriter(URL(string: url)!, _connectionManager!)
    }
    
    public func downloadFile(_ transactionId: String) throws -> FileReader {
        let url = "\(_connectionManager!.baseURL)\(ScriptingAPI.API_SCRIPT_DOWNLOAD)/\(transactionId)"
        return try FileReader(URL(string: url)!, _connectionManager!, .get)
    }

    public func unregisterScript(_ name: String) throws {
        _ = try _connectionManager?.unregisterScript(name).execute()
    }
    
    private func handleResult<T>(_ json: JSON, _ resultType: T.Type) throws -> T {
        // The String type
        if resultType.self == String.self {
            let dic = json.dictionaryObject as Any
            let checker = JSONSerialization.isValidJSONObject(dic)
            guard checker else {
                throw HiveError.jsonSerializationInvalidType(des: "HiveSDK serializate: JSONSerialization Invalid type in JSON.")
            }
            let data = try JSONSerialization.data(withJSONObject: dic, options: [])
            let str = String(data: data, encoding: String.Encoding.utf8)
            return str as! T
        }
        // The Dictionary type
        else if resultType.self == Dictionary<String, Any>.self {
            let dic = json.dictionaryObject
            return dic as! T
        }
        // The JSON type
        else if resultType.self == JSON.self {
            return json as! T
        }
        // the Data type
        else {
            let result = json.dictionaryObject as Any
            let checker = JSONSerialization.isValidJSONObject(result)
            guard checker else {
                throw HiveError.jsonSerializationInvalidType(des: "HiveSDK serializate: JSONSerialization Invalid type in JSON.")
            }
            let data = try JSONSerialization.data(withJSONObject: result, options: [])
            return data as! T
        }
    }
}
