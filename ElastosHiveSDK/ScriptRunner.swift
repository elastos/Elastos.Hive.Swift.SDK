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

public class ScriptRunner: ServiceEndpoint {
    public func callScript<T>(_ name: String, _ params: [String : Any]?, _ appDid: String?, _ resultType: T.Type) -> Promise<T> {
        
        return Promise<T> { resolver in
            var param = ["name": name] as [String : Any]
            var context = [:] as [String : Any]
            context["target_did"] = self._targetDid
            if let _ = appDid {
                context["target_app_did"] = appDid
            }
            param["context"] = context
            if let _ = params {
                param["params"] = params
            }
            let url = self.connectionManager.hiveApi.callScript()
            let header = try self.connectionManager.headers()
            let json = try AF.request(url,
                                      method: .post,
                                      parameters: param,
                                      encoding: JSONEncoding.default,
                                      headers: header).responseJSON().validateResponse()
            resolver.fulfill(try handleResult(json, resultType))
        }
    }
    
    public func callScriptUrl<T>(_ name: String, _ params: String?, _ appDid: String, _ resultType: T.Type) -> Promise<T> {
        return Promise<T> { resolver in
            let url = self.connectionManager.hiveApi.callScriptUrl(self._targetDid!, appDid, name, params)
            let header = try self.connectionManager.headers()
            let json = try AF.request(url,
                                      method: .get,
                                      encoding: JSONEncoding.default,
                                      headers: header).responseJSON().validateResponse()
            resolver.fulfill(try handleResult(json, resultType))
        }
    }
    
    public func downloadFile(_ transactionId: String) -> Promise<FileReader> {
        return Promise<FileReader> { resolver in
            let url = self.connectionManager.hiveApi.runScriptDownload(transactionId)
            _ = try self.connectionManager.headers()
            let reader = FileReader(URL(string: url)!, self.connectionManager, resolver)
            resolver.fulfill(reader)
        }
    }
    
    public func uploadFile(_ transactionId: String) -> Promise<FileWriter> {
        return Promise<FileWriter> { resolver in
            let url = self.connectionManager.hiveApi.runScriptDownload(transactionId)
            _ = try self.connectionManager.headers()
            let writer = FileWriter(URL(string: url)!, self.connectionManager)
            resolver.fulfill(writer)
        }
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
