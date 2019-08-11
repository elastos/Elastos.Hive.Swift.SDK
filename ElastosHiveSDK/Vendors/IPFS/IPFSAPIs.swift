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

@inline(__always) private func TAG() -> String { return "IPFSAPIs" }

class IPFSAPIs {

    class func publish(_ hash: String, _ authHelper: AuthHelper) -> HivePromise<Void> {
        let promise: HivePromise = HivePromise<Void> { resolver in
            let uid: String = (authHelper as! IPFSRpcHelper).param.entry.uid
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_NAME_PUBLISH.rawValue)"
            let params: [String: String] = ["uid": uid, "path": hash, "lifetime": "720h"]
            Alamofire.request(url,
                              method: .post,
                              parameters: params,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { dataResponse in
                    if dataResponse.response?.statusCode == 404 || dataResponse.response?.statusCode == NSURLErrorTimedOut {
                        isValid = false
                        validIp = validIp + 1
                        let error = HiveError.failue(des: "Network timeouot.")
                        resolver.reject(error)
                        return
                    }
                    guard dataResponse.response?.statusCode == 200 else{
                        let json = JSON(dataResponse.result.value as Any)
                        let error = HiveError.failue(des: json["Message"].stringValue)
                        resolver.reject(error)
                        return
                    }
                    resolver.fulfill(Void())
                })
        }
        return promise
    }

    class func creatFile(_ path: String, _ authHelper: AuthHelper) -> HivePromise<JSON> {
        let promise: HivePromise = HivePromise<JSON> { resolver in
            let uid: String = (authHelper as! IPFSRpcHelper).param.entry.uid
            let params: Dictionary<String, String> = ["uid": uid, "path": path,"file": "file", "create": "true", "truncate": "true"]
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_WRITE.rawValue)?\(params.queryString)"
            let str = ""
            let ipfsdata = str.data(using: .utf8)
            Alamofire.upload(multipartFormData: { data in
                data.append(ipfsdata!, withName: "file", fileName: "file", mimeType: "text/plain")
            }, to: url, encodingCompletion: { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { dataResponse in
                        if dataResponse.response?.statusCode == 404 || dataResponse.response?.statusCode == NSURLErrorTimedOut {
                            isValid = false
                            validIp = validIp + 1
                            let error = HiveError.failue(des: "Network timeouot.")
                            resolver.reject(error)
                            return
                        }
                        guard dataResponse.response?.statusCode == 200 else {
                            let json = JSON(dataResponse.result.value as Any)
                            let error = HiveError.failue(des: json["Message"].stringValue)
                            resolver.reject(error)
                            return
                        }
                        let jsonData = JSON(dataResponse.result.value as Any)
                        resolver.fulfill(jsonData)
                    })
                    break
                case .failure(let error):
                    resolver.reject(error)
                    break
                }
            })
        }
        return promise
    }

    class func writeData(_ path: String, _ withData: Data, _ authHelper: AuthHelper) -> HivePromise<Void> {
        let promise: HivePromise = HivePromise<Void> { resolver in
            let uid: String = (authHelper as! IPFSRpcHelper).param.entry.uid
            let params: Dictionary<String, String> = ["uid": uid, "path": path, "file": "file", "create": "true"]
            let url = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_WRITE.rawValue)?\(params.queryString)"
            Alamofire.upload(multipartFormData: { data in
                data.append(withData, withName: "file", fileName: "file", mimeType: "text/plain")
            }, to: url, encodingCompletion: { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { dataResponse in
                        if dataResponse.response?.statusCode == 404 || dataResponse.response?.statusCode == NSURLErrorTimedOut {
                            isValid = false
                            validIp = validIp + 1
                            let error = HiveError.failue(des: "Network timeouot.")
                            resolver.reject(error)
                            return
                        }
                        guard dataResponse.response?.statusCode == 200 else {
                            let json = JSON(dataResponse.result.value as Any)
                            let error = HiveError.failue(des: json["Message"].stringValue)
                            resolver.reject(error)
                            return
                        }
                        resolver.fulfill(Void())
                    })
                    break
                case .failure(let error):
                    resolver.reject(error)
                    break
                }
            })
        }
        return promise
    }

    class func getHash(_ path: String, _ authHelper: AuthHelper) -> HivePromise<String> {
        let promise: HivePromise = HivePromise<String> { resolver in
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_STAT.rawValue)"
            let uid: String = (authHelper as! IPFSRpcHelper).param.entry.uid
            let params: Dictionary<String, String> = ["uid": uid, "path": path]
            Alamofire.request(url,
                              method: .post,
                              parameters: params,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { dataResponse in
                    if dataResponse.response?.statusCode == 404 || dataResponse.response?.statusCode == NSURLErrorTimedOut {
                        isValid = false
                        validIp = validIp + 1
                        let error = HiveError.failue(des: "Network timeouot.")
                        resolver.reject(error)
                        return
                    }
                    guard dataResponse.response?.statusCode == 200 else {
                        let json = JSON(dataResponse.result.value as Any)
                        let error = HiveError.failue(des: json["Message"].stringValue)
                        resolver.reject(error)
                        return
                    }
                    let hash = "/ipfs/" + JSON(dataResponse.result.value as Any)["Hash"].stringValue
                    resolver.fulfill(hash)
                })
        }
        return promise
    }

    class func request(_ url: URLConvertible,
                       _ method: HTTPMethod = .post,
                       _ parameters: Parameters? = nil) -> HivePromise<JSON> {
        let promise: HivePromise = HivePromise<JSON> { resolver in
            Alamofire.request(url,
                              method: method,
                              parameters: parameters,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { dataResponse in
                    if dataResponse.response?.statusCode == 404 || dataResponse.response?.statusCode == NSURLErrorTimedOut {
                        isValid = false
                        validIp = validIp + 1
                        let error = HiveError.failue(des: "Network timeouot.")
                        resolver.reject(error)
                        return
                    }
                    guard dataResponse.response?.statusCode == 200 else {
                        let json = JSON(dataResponse.result.value as Any)
                        let error = HiveError.failue(des: json["Message"].stringValue)
                        resolver.reject(error)
                        return
                    }
                    let json = JSON(dataResponse.result.value as Any)
                    resolver.fulfill(json)
                })
        }
        return promise
    }

    class func getRemoFiel(_ url: URLConvertible,
                           _ method: HTTPMethod = .post,
                           _ parameters: Parameters? = nil)
        -> HivePromise<Data> {
            let promise: HivePromise = HivePromise<Data> { resolver in
                Alamofire.request(url,
                                  method: .post,
                                  parameters: parameters,
                                  encoding: URLEncoding.queryString,
                                  headers: nil)
                    .responseJSON(completionHandler: { dataResponse in
                        if dataResponse.response?.statusCode == 404 || dataResponse.response?.statusCode == NSURLErrorTimedOut {
                            isValid = false
                            validIp = validIp + 1
                            let error = HiveError.failue(des: "Network timeouot.")
                            resolver.reject(error)
                            return
                        }
                        guard dataResponse.response?.statusCode == 200 else {
                            let json = JSON(dataResponse.result.value as Any)
                            let error = HiveError.failue(des: json["Message"].stringValue)
                            resolver.reject(error)
                            return
                        }
                        let data = dataResponse.data ?? Data()
                        resolver.fulfill(data)
                    })
            }
            return promise
    }

}
