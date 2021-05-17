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

import ObjectMapper

internal extension DataRequest {
    
    func get<T: Mappable & HiveCheckValidProtocol>(options: JSONSerialization.ReadingOptions = .allowFragments, _ resultType: T.Type) throws -> T {
        let response1 = response(responseSerializer: JSONResponseSerializer(options: options))
        switch response1.result {
        case .success(let re):
            let json = re as! [String : Any]
            if json["_status"] as! String != "OK" {
                let errorObject = JSON(json)
                let code = errorObject["_error"] ["code"];
                let message = errorObject["_error"] ["message"];
                throw HiveError.hiveSdk(message: "get error from server: error code = \(code), message = \(message)")
            }
            if resultType == HiveResponse.self {
                let response: HiveResponse = HiveResponse(JSON: re as! [String : Any])!
                response.json = JSON(re).dictionaryObject!
                return response as! T
            } else {
                let result = T(JSON: re as! [String : Any])!
                try result.checkResponseVaild()
                return result
            }
            
        case .failure(let error):
            let e = error
            switch e {
            case .responseSerializationFailed(_):
                var des = ""
                if response1.data != nil {
                    des = String(data: response1.data!, encoding: .utf8) ?? ""
                }
                let err = HiveError.responseSerializationFailed(des: des)
                throw err
            default: break
            }
            throw error
        }
    }
}

extension DownloadRequest {
    public func get(options: JSONSerialization.ReadingOptions = .allowFragments) -> AFDownloadResponse<Any> {
        return response(responseSerializer: JSONResponseSerializer(options: options))
    }
}
