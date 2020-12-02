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

    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }

    public func registerScript(_ name: String, _ executable: Executable) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.registerScriptImp(name, nil, executable, 0)
        }
    }

    public func registerScript(_ name: String, _ condition: Condition, _ executable: Executable) -> HivePromise<Bool> {

        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.registerScriptImp(name, condition, executable, 0)
        }
    }

    private func registerScriptImp(_ name: String, _ accessCondition: Condition?, _ executable: Executable, _ tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in

            var param = ["name": name] as [String : Any]
            if let _ = accessCondition {
                param["accessCondition"] = try accessCondition!.jsonSerialize()
            }
            param["executable"] = try executable.jsonSerialize()
            let url = VaultURL.sharedInstance.registerScript()
            let response = Alamofire.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if isRelogin {
                try self.authHelper.signIn()
                registerScriptImp(name, accessCondition, executable, 1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }

    public func callScript<T>(_ name: String, _ config: CallConfig?, _ resultType: T.Type) -> HivePromise<T> {
        return self.authHelper.checkValid().then { _ -> HivePromise<T> in
            if config == nil {
                return self.callScriptImpl(name, nil, resultType, 0)
            }
            else if config!.isKind(of: UploadCallConfig.self) {
                return self.uploadImp(name, config! as! UploadCallConfig, resultType, 0)
            }
            else if config!.isKind(of: DownloadCallConfig.self) {
                return self.downloadImp(name, config! as! DownloadCallConfig, resultType, 0)
            }
            else if config!.isKind(of: GeneralCallConfig.self) {
                return self.callScriptImpl(name, (config! as! GeneralCallConfig), resultType, 0)
            }
            else {
                // This code will never be executed.
                return self.callScriptImpl(name, config as? GeneralCallConfig, resultType, 0)
            }
        }
    }

    private func callScriptImpl<T>(_ scriptName: String, _ config: GeneralCallConfig?, _ resultType: T.Type, _ tryAgain: Int) -> HivePromise<T> {
        return HivePromise<T> { resolver in
            var param = ["name": scriptName] as [String : Any]
            if config != nil && config?.params != nil {
                param["params"] = config!.params!
            }
            
            let ownerDid = authHelper.ownerDid
            if ownerDid != nil{
                var dic = ["target_did": ownerDid!]
                let appDid = config?.appDid
                if let _ = appDid {
                    dic["target_app_did"] = appDid!
                }
                param["context"] = dic
            }
            let url = VaultURL.sharedInstance.call()
            let response = Alamofire.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if isRelogin {
                try self.authHelper.signIn()
                callScriptImpl(scriptName, config, resultType, 1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            // The String type
            if resultType.self == String.self {
                let dic = json.dictionaryObject
                let data = try JSONSerialization.data(withJSONObject: dic as Any, options: [])
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
                let data = try JSONSerialization.data(withJSONObject: json.dictionaryObject as Any, options: [])
                resolver.fulfill(data as! T)
            }
        }
    }
    
    private func uploadImp<T>(_ scriptName: String, _ config: UploadCallConfig, _ resultType: T.Type, _ tryAgain: Int) -> HivePromise<T> {
        return HivePromise<T> { resolver in
            let transactionId = try uploadFirstImp(scriptName, config, 0)
            let writer = try uploadImp(transactionId)
            resolver.fulfill(writer as! T)
        }
    }
    
    private func uploadFirstImp(_ scriptName: String, _ config: UploadCallConfig, _ tryAgain: Int) throws -> String {
        
        var param = ["name": scriptName] as [String : Any]
        if config.params != nil {
            param["params"] = config.params!
        }
        let url = VaultURL.sharedInstance.call()
        let response = Alamofire.request(url,
                            method: .post,
                            parameters: param,
                            encoding: JSONEncoding.default,
                            headers: Header(authHelper).headers()).responseJSON()
        let json = try VaultApi.handlerJsonResponse(response)
        let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
        if isRelogin {
            try self.authHelper.signIn()
            return try uploadFirstImp(scriptName, config, 1)
        }
        // "upload_file" is same as the name of executable in registerScript()
        let transactionId = json["upload_file"]["transaction_id"].stringValue
        guard transactionId != "" else {
            throw HiveError.transactionIdIsNil(des: "transactionId is nil.")
        }
        return transactionId
    }
    
    private func uploadImp(_ transactionId: String) throws -> FileWriter {
        if let url = URL(string: VaultURL.sharedInstance.runScriptUpload(transactionId)) {
            let writer = FileWriter(url: url, authHelper: authHelper)
            return writer
        }
        else {
            throw HiveError.IllegalArgument(des: "Invalid url format.")
        }
    }

    private func downloadImp<T>(_ scriptName: String, _ config: DownloadCallConfig, _ resultType: T.Type, _ tryAgain: Int) -> HivePromise<T> {
        HivePromise<T> { resolver in
            let transactionId = try downloadFirstImp(scriptName, config, 0)
            downloadImp(transactionId, 0).done { reader in
                resolver.fulfill(reader as! T)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    private func downloadFirstImp(_ scriptName: String, _ config: DownloadCallConfig, _ tryAgain: Int) throws -> String {
        
        var param = ["name": scriptName] as [String : Any]
        if config.params != nil {
            param["params"] = config.params!
        }
        let url = VaultURL.sharedInstance.call()
        let response = Alamofire.request(url,
                            method: .post,
                            parameters: param,
                            encoding: JSONEncoding.default,
                            headers: Header(authHelper).headers()).responseJSON()
        let json = try VaultApi.handlerJsonResponse(response)
        let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
        if isRelogin {
            try self.authHelper.signIn()
            return try downloadFirstImp(scriptName, config, 1)
        }
        let transactionId = json["download_file"]["transaction_id"].stringValue
        guard transactionId != "" else {
            throw HiveError.transactionIdIsNil(des: "transactionId is nil.")
        }
        return transactionId
    }
    
    private func downloadImp(_ transactionId: String, _ tryAgain: Int) -> HivePromise<FileReader> {
        HivePromise<FileReader> { resolver in
            let url = URL(string: VaultURL.sharedInstance.runScriptDownload(transactionId))
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
                self.authHelper.retryLogin().then { success -> HivePromise<FileReader> in
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
