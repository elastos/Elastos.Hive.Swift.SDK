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

public class ScriptingAPI {
    public static let API_SCRIPT_UPLOAD = "/api/v2/vault/scripting/stream"
    public static let API_SCRIPT_DOWNLOAD = "/api/v2/vault/scripting/stream"
}

extension ConnectionManager {
    
    public func registerScript(_ scriptName: String, _ params: RegScriptParams) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/scripting/\(scriptName)"
        return try self.createDataRequest(url, .put, params.toJSON())
    }
    
    public func runScript(_ scriptName: String, _ params: RunScriptParams) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/scripting/\(scriptName)"
        return try self.createDataRequest(url, .patch, params.toJSON())
    }
    
    public func runScriptUrl(_ scriptName: String, _ targetDid: String, _ targetAppDid: String, _ params: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/scripting/\(scriptName)/\(targetDid)@\(targetAppDid)/\(params.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
        return try self.createDataRequest(url, .get, nil)
    }
    
    public func downloadFile(_ transactionId: String) throws -> DataRequest {
        let url = "/api/v2/vault/scripting/stream/\(transactionId)"
        return try self.createDataRequest(url, .get, nil)
    }
    
    public func unregisterScript(_ scriptName: String) throws -> DataRequest {
        let url = "/api/v2/vault/scripting/\(scriptName)"
        return try self.createDataRequest(url, .delete, nil)
    }
}
//
//extension HiveAPi {
//    func registerScript() -> String {
//        return self.baseURL + self.apiPath + "/scripting/set_script"
//    }
//
//    func callScript() -> String {
//        return self.baseURL + self.apiPath + "/scripting/run_script"
//    }
//
//    func callScriptUrl(_ targetDid: String, _ appDid: String, _ scriptName: String, _ params: String?) -> String {
//        var paramsEncodingString = ""
//        if params != nil {
//            paramsEncodingString = "?params=" + params!.percentEncodingString()
//        }
//        return self.baseURL + self.apiPath + "/scripting/run_script_url/" + targetDid + "@" + appDid + "/" + scriptName + paramsEncodingString
//    }
//
//    func runScriptUpload(_ transactionId: String) -> String {
//        return self.baseURL + self.apiPath + "/scripting/run_script_upload/\(transactionId)"
//    }
//
//    func runScriptDownload(_ transactionId: String) -> String {
//        return self.baseURL + self.apiPath + "/scripting/run_script_download/\(transactionId)"
//    }
//
//}
