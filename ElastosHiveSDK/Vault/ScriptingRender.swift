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

//public class ScriptingServiceRender: ScriptingProtocol {
//    private var _serviceEndpoint: ServiceEndpoint
//    
//    public init(_ serviceEndpoint: ServiceEndpoint) {
//        self._serviceEndpoint = serviceEndpoint
//    }
//    
//    public func registerScript(_ name: String, _ executable: Executable, _ allowAnonymousUser: Bool, _ allowAnonymousApp: Bool) -> Promise<Bool> {
//        return self.registerScript(name, nil, executable, allowAnonymousUser, allowAnonymousApp)
//    }
//
//    public func registerScript(_ name: String, _ condition: Condition?, _ executable: Executable, _ allowAnonymousUser: Bool, _ allowAnonymousApp:  Bool) -> Promise<Bool> {
//        return Promise<Bool> { resolver in
//            let params = RegisterScriptRequestParams()
//            params.name = name
//            params.allowAnonymousUser = allowAnonymousUser
//            params.allowAnonymousApp = allowAnonymousApp
//            if condition != nil {
//                params.condition = condition!
//            }
//            params.executable = executable
//            print(params.toJSON())
//            let url = self._serviceEndpoint.connectionManager.hiveApi.registerScript()
//            let header = try self._serviceEndpoint.connectionManager.headers()
//            _ = try HiveAPi.request(url: url, method: .post, parameters: params.toJSON(), headers: header).get(RegisterScriptResponse.self)
//            resolver.fulfill(true)
//        }
//    }
//    
//    public func callScript<T>(_ name: String, _ params: [String : Any]?, _ targetDid: String?, _ targetAppDid: String?, _ resultType: T.Type) -> Promise<T> {
//        return Promise<T> { resolver in
//            let context = ScriptContext()
//            context.targetDid = targetDid
//            context.targetAppDid = targetAppDid
//            
//            let requestParams = CallScriptRequestParams()
//            requestParams.name = name
//            requestParams.context = context
//            if params != nil {
//                requestParams.params = params!
//            }
//
//            let url = self._serviceEndpoint.connectionManager.hiveApi.callScript()
//            let header = try self._serviceEndpoint.connectionManager.headers()
//            let response = try HiveAPi.request(url: url, method: .post, parameters: requestParams.toJSON(), headers: header).get(HiveResponse.self)
//            resolver.fulfill(try handleResult(JSON(response.json), resultType))
//        }
//    }
//    
//    public func callScriptUrl<T>(_ name: String, _ params: String?, _ targetDid: String?, _ targetAppDid: String?, _ resultType: T.Type) -> Promise<T> {
//        return Promise<T> { resolver in
//            let url = self._serviceEndpoint.connectionManager.hiveApi.callScriptUrl(targetDid!, targetAppDid!, name, params)
//            let header = try self._serviceEndpoint.connectionManager.headers()
//            let response = try AF.request(url,
//                                      method: .get,
//                                      encoding: JSONEncoding.default,
//                                      headers: header).get(HiveResponse.self)
//            resolver.fulfill(try handleResult(JSON(response.json), resultType))
//        }
//    }
//    
//    public func downloadFile<T>(_ transactionId: String, _ resultType: T.Type) -> Promise<T>  {
//        return Promise<T> { resolver in
//            let url = self._serviceEndpoint.connectionManager.hiveApi.runScriptDownload(transactionId)
//            _ = try self._serviceEndpoint.connectionManager.headers()
//            if resultType.self == FileReader.self {
//                do {
//                    let reader = try FileReader(URL(string: url)!, self._serviceEndpoint.connectionManager, resolver, .post)
//                    resolver.fulfill(reader as! T)
//                } catch {
//                    resolver.reject(error)
//                }
//                
//            } else {
//                resolver.reject(HiveError.InvalidParameterException("only support FileReader as resultType"))
//            }
//        }
//    }
//        
//    public func uploadFile<T>(_ transactionId: String, _ resultType: T.Type) -> Promise<T> {
//        return Promise<T> { resolver in
//            let url = self._serviceEndpoint.connectionManager.hiveApi.runScriptUpload(transactionId)
//            _ = try self._serviceEndpoint.connectionManager.headers()
//            if resultType.self == FileWriter.self {
//                let writer = FileWriter(URL(string: url)!, self._serviceEndpoint.connectionManager)
//                resolver.fulfill(writer as! T)
//            } else {
//                resolver.reject(HiveError.InvalidParameterException("only support FileWriter as resultType"))
//            }
//        }
//    }
//    
//    private func handleResult<T>(_ json: JSON, _ resultType: T.Type) throws -> T {
//        // The String type
//        if resultType.self == String.self {
//            let dic = json.dictionaryObject as Any
//            let checker = JSONSerialization.isValidJSONObject(dic)
//            guard checker else {
//                throw HiveError.jsonSerializationInvalidType(des: "HiveSDK serializate: JSONSerialization Invalid type in JSON.")
//            }
//            let data = try JSONSerialization.data(withJSONObject: dic, options: [])
//            let str = String(data: data, encoding: String.Encoding.utf8)
//            return str as! T
//        }
//        // The Dictionary type
//        else if resultType.self == Dictionary<String, Any>.self {
//            let dic = json.dictionaryObject
//            return dic as! T
//        }
//        // The JSON type
//        else if resultType.self == JSON.self {
//            return json as! T
//        }
//        // the Data type
//        else {
//            let result = json.dictionaryObject as Any
//            let checker = JSONSerialization.isValidJSONObject(result)
//            guard checker else {
//                throw HiveError.jsonSerializationInvalidType(des: "HiveSDK serializate: JSONSerialization Invalid type in JSON.")
//            }
//            let data = try JSONSerialization.data(withJSONObject: result, options: [])
//            return data as! T
//        }
//    }
//}
