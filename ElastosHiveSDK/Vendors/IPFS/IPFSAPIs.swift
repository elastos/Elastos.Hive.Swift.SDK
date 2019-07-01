import Foundation
import Alamofire

@inline(__always) private func TAG() -> String { return "IPFSAPIs" }

class IPFSAPIs {

    class func publish(_ hash: String, _ authHelper: AuthHelper) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            let uid = (authHelper as! IPFSAuthHelper).param.uid
            let params = ["uid": uid, "path": hash]
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_NAME_PUBLISH.rawValue
            Alamofire.request(url,
                              method: .post,
                              parameters: params,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { dataResponse in
                    guard dataResponse.response?.statusCode == 200 else{
                        let error = HiveError.failue(des: dataResponse.toString())
                        resolver.reject(error)
                        return
                    }
                    resolver.fulfill(HiveVoid())
                })
        }
        return promise
    }

    class func creatFile(_ path: String, _ authHelper: AuthHelper) -> HivePromise<JSON> {
        let promise = HivePromise<JSON> { resolver in
            let uid = (authHelper as! IPFSAuthHelper).param.uid
            let params = ["uid": uid, "path": path,"file": "file", "create": "true", "truncate": "true"]
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_WRITE.rawValue + "?" + params.queryString
            let str = ""
            let ipfsdata = str.data(using: .utf8)
            Alamofire.upload(multipartFormData: { data in
                data.append(ipfsdata!, withName: "file", fileName: "file", mimeType: "text/plain")
            }, to: url, encodingCompletion: { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { dataResponse in
                        guard dataResponse.response?.statusCode == 200 else {
                            let error = HiveError.failue(des: dataResponse.toString())
                            resolver.reject(error)
                            return
                        }
                        let jsonData = JSON(dataResponse.result.value as Any)
                        resolver.fulfill(jsonData)
                    })
                    break
                case .failure(let error):
                    let error = HiveError.failue(des: error.localizedDescription)
                    resolver.reject(error)
                    break
                }
            })
        }
        return promise
    }

    class func writeData(_ path: String, _ withData: Data, _ authHelper: AuthHelper) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            let uid = (authHelper as! IPFSAuthHelper).param.uid
            let params = ["uid": uid, "path": path, "file": "file", "create": "true"]
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_WRITE.rawValue + "?" + params.queryString
            Alamofire.upload(multipartFormData: { data in
                data.append(withData, withName: "file", fileName: "file", mimeType: "text/plain")
            }, to: url, encodingCompletion: { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { dataResponse in
                        guard dataResponse.response?.statusCode == 200 else {
                            let error = HiveError.failue(des: dataResponse.toString())
                            resolver.reject(error)
                            return
                        }
                        resolver.fulfill(HiveVoid())
                    })
                    break
                case .failure(let error):
                    let error = HiveError.failue(des: error.localizedDescription)
                    resolver.reject(error)
                    break
                }
            })
        }
        return promise
    }

    class func getHash(_ path: String, _ authHelper: AuthHelper) -> HivePromise<String> {
        let promise = HivePromise<String> { resolver in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
            let uid = (authHelper as! IPFSAuthHelper).param.uid
            let params = ["uid": uid, "path": path]
            Alamofire.request(url,
                              method: .post,
                              parameters: params,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { dataResponse in
                    guard dataResponse.response?.statusCode == 200 else {
                        let error = HiveError.failue(des: dataResponse.toString())
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
        let promise = HivePromise<JSON> { resolver in
            Alamofire.request(url,
                              method: method,
                              parameters: parameters,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { dataResponse in
                    guard dataResponse.response?.statusCode == 200 else {
                        let error = HiveError.failue(des: dataResponse.toString())
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
            let promise = HivePromise<Data> { resolver in
                Alamofire.request(url,
                                  method: .post,
                                  parameters: parameters,
                                  encoding: URLEncoding.queryString,
                                  headers: nil)
                    .responseJSON(completionHandler: { dataResponse in
                        guard dataResponse.response?.statusCode == 200 else {
                            let error = HiveError.failue(des: dataResponse.toString())
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
