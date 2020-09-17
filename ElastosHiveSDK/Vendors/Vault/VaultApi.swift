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
    
    class func request(url: URLConvertible,
                        method: HTTPMethod = .post,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = JSONEncoding.default,
                        headers: HTTPHeaders? = nil) -> HivePromise<JSON> {
        return HivePromise<JSON> { resolver in
            Alamofire.request(url,
                              method: method,
                              parameters: parameters,
                              encoding: encoding,
                              headers: headers)
                .responseJSON { dataResponse in
                    switch dataResponse.result {
                    case .success(let re):
                        let rejson = JSON(re)
                        let status = rejson["_status"].stringValue
                        guard status == "OK" else {
                            var dic: [String: String] = [: ]
                            rejson.forEach { key, value in
                                dic[key] = value.stringValue
                            }
                            let err = HiveError.failues(des: dic)
                            resolver.reject(err)
                            return
                        }
                        resolver.fulfill(rejson)
                    case .failure(let error):
                        resolver.reject(error)
                    }
            }
        }
    }

    class func requestWithBool(url: URLConvertible,
                        method: HTTPMethod = .post,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = JSONEncoding.default,
                        headers: HTTPHeaders? = nil, handler: HiveCallback<Bool>? = nil) -> HivePromise<Bool> {
        return HivePromise<Bool> { resolver in
            Alamofire.request(url,
                              method: method,
                              parameters: parameters,
                              encoding: encoding,
                              headers: headers)
                .responseJSON { dataResponse in
                    switch dataResponse.result {
                    case .success(let re):
                        let rejson = JSON(re)
                        let status = rejson["_status"].stringValue
                        guard status == "OK" else {
                            var dic: [String: String] = [: ]
                            rejson.forEach { key, value in
                                dic[key] = value.stringValue
                            }
                            let err = HiveError.failues(des: dic)
                            handler?.runError(err)
                            resolver.reject(err)
                            return
                        }
                        handler?.didSucceed(true)
                        resolver.fulfill(true)
                    case .failure(let error):
                        handler?.runError(HiveError.netWork(des: error))
                        resolver.reject(error)
                    }
            }
        }
    }

    class func requestWithResponseData(url: URLConvertible,
                        method: HTTPMethod = .post,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = JSONEncoding.default,
                        headers: HTTPHeaders? = nil) -> HivePromise<Bool> {
        return HivePromise<Bool> { resolver in
            print(url)
            Alamofire.request(url,
                              method: method,
                              parameters: parameters,
                              encoding: encoding,
                              headers: headers)
                .responseData { responseData in
                    let re = String(data: responseData.data!, encoding: .utf8)
                    print(re)
                    print(re)
            }
        }
    }

    class func requestWithInsert(url: URLConvertible,
                        method: HTTPMethod = .post,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = JSONEncoding.default,
                        headers: HTTPHeaders? = nil, handler: HiveCallback<InsertResult>) -> HivePromise<InsertResult> {
        return HivePromise<InsertResult> { resolver in
            Alamofire.request(url,
                              method: method,
                              parameters: parameters,
                              encoding: encoding,
                              headers: headers)
                .responseJSON { dataResponse in
                    switch dataResponse.result {
                    case .success(let re):
                        let rejson = JSON(re)
                        let status = rejson["_status"].stringValue
                        guard status == "OK" else {
                            var dic: [String: String] = [: ]
                            rejson.forEach { key, value in
                                dic[key] = value.stringValue
                            }
                            let err = HiveError.failues(des: dic)
                            resolver.reject(err)
                            return
                        }
                        let insertResult = InsertResult(rejson)
                        handler.didSucceed(insertResult)
                        resolver.fulfill(insertResult)
                    case .failure(let error):
                        handler.runError(HiveError.netWork(des: error))
                        resolver.reject(error)
                    }
            }
        }
    }

    class func nodeAuth(url: URLConvertible,
                        method: HTTPMethod = .post,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = JSONEncoding.default,
                        headers: HTTPHeaders? = nil) -> HivePromise<JSON> {
        return HivePromise<JSON> { resolver in
            Alamofire.request(url,
                              method: method,
                              parameters: parameters,
                              encoding: encoding,
                              headers: headers)
                .responseJSON { dataResponse in
                    switch dataResponse.result {
                    case .success(let re):
                        let rejson = JSON(re)
                        let status = rejson["_status"].stringValue
                        guard status == "OK" else {
                            var dic: [String: String] = [: ]
                            rejson.forEach { key, value in
                                dic[key] = value.stringValue
                            }
                            let err = HiveError.failues(des: dic)
                            resolver.reject(err)
                            return
                        }
                        resolver.fulfill(rejson)
                    case .failure(let error):
                        resolver.reject(error)
                    }
            }
        }
    }
}
