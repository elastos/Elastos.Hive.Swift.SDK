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

class VaultApi: NSObject {
    class func checkResponseIsError(_  json: JSON) -> Bool {
        let status = json["_status"].stringValue
        if status == "ERR" {
            return false
        }
        else {
            return true
        }
    }

    class func checkResponseCanRetryLogin(_  json: JSON, tryAgain: Int) -> Bool {
        let errorCode = json["_error"]["code"].intValue
        let errorMessage = json["_error"]["message"].stringValue
        if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
            return true
        } else {
            return false
        }
    }
    
    class func printDebugLogForNetwork(_ response: DataResponse<Any>) {
        Log.d("Hive Debug ==> request url ->", response.request?.url?.debugDescription ?? "")
        Log.d("Hive Debug ==> request headers ->", response.request?.allHTTPHeaderFields?.debugDescription ?? "")
        Log.d("Hive Debug ==> response Code ->", response.response?.statusCode.description ?? "")
        Log.d("Hive Debug ==> response body ->", response.result.debugDescription)
    }
    
    class func handlerJsonResponse(_ response: DataResponse<Any>)throws -> JSON {
        switch response.result {
        case .success(let re):
            let json = JSON(re)
            return json
        case .failure(let error):
            throw error
        }
    }
    
    class func handlerJsonResponseCanRelogin(_  json: JSON, tryAgain: Int) throws -> Bool {
        let status = json["_status"].stringValue
        if status == "ERR" {
            let errorCode = json["_error"]["code"].intValue
            let errorMessage = json["_error"]["message"].stringValue
            if errorCode == 401 && errorMessage == "auth failed" && tryAgain < 1 {
                return true
            } else {
                throw HiveError.failure(des: HiveError.praseError(json))
            }
        }
        else {
            return false
        }
    }
    
    class func handlerDataResponse(_  result: DataResponse<Data>, _ tryAgain: Int)throws -> Bool {
        if result.result.isSuccess {
            let code = result.response?.statusCode
            guard let _ = code else {
                throw HiveError.failure(des: "Unknow error.")
            }
            
            guard 200...299 ~= code! else {
                if result.response?.statusCode == 401 && tryAgain < 1  {
                    return true
                }
                else {
                    if result.result.error != nil {
                        throw HiveError.netWork(des: result.result.error)
                    }
                    else if result.data != nil{
                        throw HiveError.failure(des: String(data: result.data!, encoding: .utf8))
                    }
                    else {
                        throw HiveError.failure(des: "scripting download ERROR: ")
                    }
                }
            }
        }
        else {
            throw HiveError.failure(des: result.result.error?.localizedDescription)
        }
        return false
    }
}
