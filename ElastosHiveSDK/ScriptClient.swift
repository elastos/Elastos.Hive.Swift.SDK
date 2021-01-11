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

public class ScriptClient: ScriptingProtocol {
    private static let TAG = "ScriptClient"
    private var authHelper: VaultAuthHelper
    private var vaultUrl: VaultURL

    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
        self.vaultUrl = self.authHelper.vaultUrl
    }

    public func registerScript(_ name: String, _ executable: Executable, _ allowAnonymousUser: Bool, _ allowAnonymousApp: Bool) -> Promise<Bool> {
        return authHelper.checkValid().then { _ -> Promise<Bool> in
            return self.registerScriptImp(name, nil, executable, allowAnonymousUser, allowAnonymousApp, 0)
        }
    }

    public func registerScript(_ name: String, _ condition: Condition, _ executable: Executable, _ allowAnonymousUser: Bool, _ allowAnonymousApp: Bool) -> Promise<Bool> {

        return authHelper.checkValid().then { _ -> Promise<Bool> in
            return self.registerScriptImp(name, condition, executable, allowAnonymousUser, allowAnonymousApp, 0)
        }
    }

    private func registerScriptImp(_ name: String, _ accessCondition: Condition?, _ executable: Executable,_ allowAnonymousUser: Bool, _ allowAnonymousApp: Bool, _ tryAgain: Int) -> Promise<Bool> {
        Promise<Bool> { resolver in

            var param = ["name": name] as [String : Any]
            param["allowAnonymousUser"] = allowAnonymousUser
            param["allowAnonymousApp"] = allowAnonymousApp
            if let _ = accessCondition {
                param["accessCondition"] = try accessCondition!.jsonSerialize()
            }
            param["executable"] = try executable.jsonSerialize()
            let url = vaultUrl.registerScript()
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if isRelogin {
                try self.authHelper.signIn()
                registerScriptImp(name, accessCondition, executable, allowAnonymousUser, allowAnonymousApp, 1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }

    public func callScript<T>(_ name: String, _ params: [String : Any]?, _ appDid: String?, _ resultType: T.Type) -> Promise<T> {
        return self.authHelper.checkValid().then { _ -> Promise<T> in
            return self.callScriptImpl(name, params, appDid, resultType, 0)
        }
    }

    private func callScriptImpl<T>(_ scriptName: String, _ params: [String: Any]?, _ appDid: String?, _ resultType: T.Type, _ tryAgain: Int) -> Promise<T> {
        return Promise<T> { resolver in
            var param = ["name": scriptName] as [String : Any]
            if let _ = params {
                param["params"] = params
            }
            
            if let ownerDid = authHelper.ownerDid {
                var dic = ["target_did": ownerDid]
                if let _ = appDid {
                    dic["target_app_did"] = appDid!
                }
                param["context"] = dic
            }
            let url = vaultUrl.call()
            let response = AF.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: HiveHeader(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if isRelogin {
                try self.authHelper.signIn()
                callScriptImpl(scriptName, params, appDid, resultType, 1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            // The String type
            if resultType.self == String.self {
                let dic = json.dictionaryObject as Any
                let checker = JSONSerialization.isValidJSONObject(dic)
                guard checker else {
                    throw HiveError.jsonSerializationInvalidType(des: "HiveSDK serializate: JSONSerialization Invalid type in JSON.")
                }
                let data = try JSONSerialization.data(withJSONObject: dic, options: [])
                let str = String(data: data, encoding: String.Encoding.utf8)
                resolver.fulfill(str as! T)
            }
            // The Dictionary type
            else if resultType.self == Dictionary<String, Any>.self {
                let dic = json.dictionaryObject
                resolver.fulfill(dic as! T)
            }
            // The JSON type
            else if resultType.self == JSON.self {
                resolver.fulfill(json as! T)
            }
            // the Data type
            else {
                let result = json.dictionaryObject as Any
                let checker = JSONSerialization.isValidJSONObject(result)
                guard checker else {
                    throw HiveError.jsonSerializationInvalidType(des: "HiveSDK serializate: JSONSerialization Invalid type in JSON.")
                }
                let data = try JSONSerialization.data(withJSONObject: result, options: [])
                resolver.fulfill(data as! T)
            }
        }
    }
    
    public func uploadFile(_ transactionId: String) -> Promise<FileWriter> {
        return self.authHelper.checkValid().then { _ -> Promise<FileWriter> in
            return self.uploadImp(transactionId)
        }
    }
    
    private func uploadImp(_ transactionId: String) -> Promise<FileWriter> {
        return Promise<FileWriter> { resolver in
            if let url = URL(string: vaultUrl.runScriptUpload(transactionId)) {
                let writer = FileWriter(url: url, authHelper: authHelper)
                resolver.fulfill(writer)
            }
            else {
                throw HiveError.IllegalArgument(des: "Invalid url format.")
            }
        }
    }

    public func downloadFile(_ transactionId: String) -> Promise<FileReader> {
        return self.authHelper.checkValid().then { _ -> Promise<FileReader> in
            return self.downloadImp(transactionId, 0)
        }
    }
    
    private func downloadImp(_ transactionId: String, _ tryAgain: Int) -> Promise<FileReader> {
        return Promise<FileReader> { resolver in
            let url = URL(string: vaultUrl.runScriptDownload(transactionId))
            guard (url != nil) else {
                resolver.reject(HiveError.IllegalArgument(des: "Invalid url format."))
                return
            }
            let reader = FileReader(url: url!, authHelper: authHelper, method: .post, resolver: resolver)
            reader.authFailure = { error in
                if tryAgain >= 1 {
                    resolver.reject(error)
                    return
                }
                self.authHelper.retryLogin().then { success -> Promise<FileReader> in
                    return self.downloadImp(transactionId, 1)
                }.done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
        }
    }
}
