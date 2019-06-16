import Foundation
import Alamofire

@inline(__always) private func TAG() -> String { return "IPFSAPIs" }

class IPFSAPIs {

    class func publish(_ path: String) -> HivePromise<Bool> {

        let promise = HivePromise<Bool> { resolver in
            let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
            getHash(uid, path: path).done { (hash) in
                let params = ["uid": uid, "path": hash]
                let url = IPFSURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_NAME_PUBLISH.rawValue
                Alamofire.request(url,
                                  method: .post,
                                  parameters: params,
                                  encoding: URLEncoding.queryString,
                                  headers: nil)
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else{
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            resolver.reject(error)
                            return
                        }
                        resolver.fulfill(true)
                    })
                }.catch({ (error) in
                    let hiveError = HiveError.failue(des: error.localizedDescription)
                    resolver.reject(hiveError)
                })
        }
        return promise
    }

    class func creatFile(_ path: String) -> HivePromise<JSON> {
        let promise = HivePromise<JSON> { resolver in
            let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
            let params = ["uid": uid, "path": path, "file": "file", "create": "true"]
            let url = IPFSURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_WRITE.rawValue + "?" + params.queryString
            let str = ""
            let ipfsdata = str.data(using: .utf8)
            Alamofire.upload(multipartFormData: { (data) in
                data.append(ipfsdata!, withName: "file", fileName: "file", mimeType: "text/plain")
            }, to: url, encodingCompletion: { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else {
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
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

    class func createDirectory(_ path: String) -> HivePromise<JSON> {
        let promise = HivePromise<JSON> { resolver in
            let url = IPFSURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_MKDIR.rawValue
            let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
            let param = ["uid": uid,"path": path]
            Alamofire.request(url,
                              method: .post,
                              parameters: param,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.response?.statusCode == 200 else{
                        let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                        resolver.reject(error)
                        return
                    }
                    let jsonData = JSON(dataResponse.result.value as Any)
                    resolver.fulfill(jsonData)
                })
        }
        return promise
    }

    class func moveTo(_ originPath: String, _ newPath: String) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            let url = IPFSURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_MV.rawValue
            let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
            let params = ["uid": uid, "source": originPath + "/", "dest": newPath]
            Alamofire.request(url,
                              method: .post,
                              parameters: params,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.response?.statusCode == 200 else {
                        let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                        resolver.reject(error)
                        return
                    }
                    resolver.fulfill(true)
                })
        }
        return promise
    }

    class func copyTo(_ originPath: String, _ newParh: String) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
            getHash(uid, path: originPath).done({ (hash) in
                let url = IPFSURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_CP.rawValue
                let params = ["uid": uid, "source": hash, "dest": newParh + "/"]
                Alamofire.request(url,
                                  method: .post,
                                  parameters: params,
                                  encoding: URLEncoding.queryString,
                                  headers: nil)
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else {
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            resolver.reject(error)
                            return
                        }
                        resolver.fulfill(true)
                    })
            }).catch({ (error) in
                
            })
        }
        return promise
    }

    class func deleteItem(_ path: String) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            let url = IPFSURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_RM.rawValue
            let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
            let params = ["uid": uid, "path": path, "recursive": true] as [String : Any]
            Alamofire.request(url,
                              method: .post,
                              parameters: params,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.response?.statusCode == 200 else {
                        let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                        resolver.reject(error)
                        return
                    }
                    resolver.fulfill(true)
                })
        }
        return promise
    }

    class func writeData(_ path: String, _ withData: Data) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
            let params = ["uid": uid, "path": path, "file": "file", "create": "true"]
            let url = IPFSURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_WRITE.rawValue + "?" + params.queryString
            Alamofire.upload(multipartFormData: { (data) in
                data.append(withData, withName: "file", fileName: "file", mimeType: "text/plain")
            }, to: url, encodingCompletion: { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else {
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            resolver.reject(error)
                            return
                        }
                        resolver.fulfill(true)
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

    class func getHash(_ uid: String, path: String) -> HivePromise<String> {
        let promise = HivePromise<String> { resolver in
            let url = IPFSURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
            let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
            let params = ["uid": uid, "path": "/"]
            Alamofire.request(url,
                              method: .post,
                              parameters: params,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.response?.statusCode == 200 else {
                        let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                        resolver.reject(error)
                        return
                    }
                    let hash = "/ipfs/" + JSON(dataResponse.result.value as Any)["Hash"].stringValue
                    resolver.fulfill(hash)
                })
        }
        return promise
    }
}
