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

class OneDriveAPIs: NSObject {
    
    class func request(url: URLConvertible,
                       method: HTTPMethod = .get,
                       parameters: Parameters? = nil,
                       encoding: ParameterEncoding = URLEncoding.default,
                       headers: HTTPHeaders? = nil) -> HivePromise<JSON> {
        return HivePromise<JSON> { resolver in
            Alamofire.request(url, method: method,
                              parameters: parameters,
                              encoding: encoding,
                              headers: headers)
                .responseJSON { dataResponse in
                    guard dataResponse.response?.statusCode != statusCode.unauthorized.rawValue else {
                        let error: HiveError = HiveError.failue(des: TOKEN_INVALID)
                        resolver.reject(error)
                        return
                    }
                    guard (200 ... 299) ~= dataResponse.response!.statusCode else{
                        let responsejson: JSON = JSON(dataResponse.result.value as Any)
                        let errorjson: JSON = JSON(responsejson["error"])
                        let error: HiveError = HiveError.failue(des: errorjson["message"].stringValue)
                        resolver.reject(error)
                        return
                    }
                    let jsonData: JSON = JSON(dataResponse.result.value as Any)
                    resolver.fulfill(jsonData)
            }
        }
    }
    
    class func uploadWriteData(data: Data, to: URLConvertible,
                               method: HTTPMethod = .put,
                               headers: HTTPHeaders) -> HivePromise<Void> {
        return HivePromise<Void> { resolver in
            Alamofire.upload(data,
                             to: to,
                             method: method,
                             headers: headers)
                .responseJSON(completionHandler: { dataResponse in
                    guard dataResponse.response?.statusCode != statusCode.unauthorized.rawValue else {
                        let error: HiveError = HiveError.failue(des: TOKEN_INVALID)
                        resolver.reject(error)
                        return
                    }
                    guard dataResponse.response?.statusCode == statusCode.created.rawValue || dataResponse.response?.statusCode == statusCode.ok.rawValue else {
                        let json: JSON = JSON(JSON(dataResponse.result.value as Any)["error"])
                        let error: HiveError = HiveError.failue(des: json["message"].stringValue)
                        resolver.reject(error)
                        return
                    }
                    resolver.fulfill(Void())
            })
        }
    }

    class func getRemoteFile(url: URLConvertible, headers: HTTPHeaders) -> HivePromise<Data> {
        return HivePromise<Data> {resolver in
            Alamofire.request(url, method: .get,
                              parameters: nil,
                              encoding: JSONEncoding.default,
                              headers: headers)
                .responseData { dataResponse in
                    guard dataResponse.response?.statusCode != statusCode.unauthorized.rawValue else {
                        let error: HiveError = HiveError.failue(des: TOKEN_INVALID)
                        resolver.reject(error)
                        return
                    }
                    guard dataResponse.response?.statusCode == 200 else{
                        let json: JSON = JSON(JSON(dataResponse.result.value as Any)["error"])
                        let error: HiveError = HiveError.failue(des: json["message"].stringValue)
                        resolver.reject(error)
                        return
                    }
                    let data: Data = dataResponse.data ?? Data()
                    resolver.fulfill(data)
            }
        }
    }
    
    class func createUploadSession(url: URLConvertible,
                                   method: HTTPMethod = .post,
                                   parameters: Parameters? = nil,
                                   encoding: ParameterEncoding = JSONEncoding.default,
                                   headers: HTTPHeaders) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            Alamofire.request(url,
                              method: method,
                              parameters: parameters,
                              encoding: encoding,
                              headers: headers)
                .responseJSON { dataResponse in
                    switch dataResponse.result {
                    case .success(let re):
                        let uploadUrl: String = JSON(re)["uploadUrl"].stringValue
                        resolver.fulfill(uploadUrl)
                    case .failure(let error):
                        resolver.reject(error)
                    }
            }
        }
    }
}
