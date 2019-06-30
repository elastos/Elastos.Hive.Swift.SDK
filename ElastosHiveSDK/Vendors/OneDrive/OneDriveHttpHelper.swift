

import Foundation
import Alamofire

class OneDriveHttpHelper: NSObject {

    class func request(url: URLConvertible,
                       method: HTTPMethod = .get,
                       parameters: Parameters? = nil,
                       encoding: ParameterEncoding = URLEncoding.default,
                       headers: HTTPHeaders, avalidCode: Int,
                       _ authHelper: AuthHelper) -> HivePromise<JSON> {
        let promise = HivePromise<JSON> { resolver in
            Alamofire.request(url, method: method,
                              parameters: parameters,
                              encoding: encoding,
                              headers: headers)
                .responseJSON { dataResponse in
                    guard dataResponse.response?.statusCode != 401 else {
                        (authHelper as! OneDriveAuthHelper).token?.expiredTime = ""
                        KeyChainStore.writeback((authHelper as! OneDriveAuthHelper).token!,
                                                (authHelper as! OneDriveAuthHelper).authEntry,
                                                .oneDrive)
                        let error = HiveError.failue(des: TOKEN_INVALID)
                        resolver.reject(error)
                        return
                    }
                    guard dataResponse.response?.statusCode == avalidCode || dataResponse.response?.statusCode == 200 else{
                        let error = HiveError.failue(des: dataResponse.toString())
                        resolver.reject(error)
                        return
                    }
                    var jsonData = JSON(dataResponse.result.value as Any)
                    if avalidCode == 202 {
                        jsonData = JSON(dataResponse.response?.allHeaderFields as Any)
                    }
                    resolver.fulfill(jsonData)
            }
        }
        return promise
    }

    class func upload(data: Data, to: URLConvertible,
                      method: HTTPMethod = .get,
                      headers: HTTPHeaders,
                      avalidCode: Int, _ authHelper: AuthHelper) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            Alamofire.upload(data, to: to,
                             method: method,
                             headers: headers)
                .responseJSON { dataResponse in
                    guard dataResponse.response?.statusCode != 401 else {
                        (authHelper as! OneDriveAuthHelper).token?.expiredTime = ""
                        KeyChainStore.writeback((authHelper as! OneDriveAuthHelper).token!,
                                                (authHelper as! OneDriveAuthHelper).authEntry,
                                                .oneDrive)
                        let error = HiveError.failue(des: TOKEN_INVALID)
                        resolver.reject(error)
                        return
                    }
                    guard dataResponse.response?.statusCode == 200 || dataResponse.response?.statusCode == avalidCode
                        else{
                            let error = HiveError.failue(des: dataResponse.toString())
                            resolver.reject(error)
                            return
                    }
                    resolver.fulfill(HiveVoid())
            }
        }
        return promise
    }

    class func pollingCopyresult(_ url: String) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            Alamofire.request(url,
                              method: .get,
                              parameters: nil, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { (dataResponse) in
                    let jsonData = JSON(dataResponse.result.value as Any)
                    let stat = jsonData["status"].stringValue
                    if stat == "completed" {
                        resolver.fulfill(HiveVoid())
                        return
                    }else if stat == "failed" {
                        let error = HiveError.failue(des: "Operation failed")
                        resolver.reject(error)
                        return
                    }else {
                        self.pollingCopyresult(url).done({ (void) in
                            resolver.fulfill(HiveVoid())
                        }).catch({ (error) in
                            resolver.reject(error)
                        })
                    }
            }
        }
        return promise
    }

    class func pollingDowloadresult(_ url: String) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            Alamofire.request(url,
                              method: .get,
                              parameters: nil, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { (dataResponse) in
                    //                TODO
            }
        }
        return promise
    }

    class func getRemoteFile(authHelper: AuthHelper, url: String) -> HivePromise<Data> {
        let promise = HivePromise<Data> {resolver in
            _ = authHelper.checkExpired().done { result in
                Alamofire.request(url, method: .get,
                                  parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: OneDriveHttpHeader.headers(authHelper))
                    .responseData { dataResponse in
                        let jsonStr = String(data: dataResponse.data!, encoding: .utf8) ?? ""
                        guard dataResponse.response?.statusCode != 401 else {
                            (authHelper as! OneDriveAuthHelper).token?.expiredTime = ""
                            KeyChainStore.writeback((authHelper as! OneDriveAuthHelper).token!,
                                                    (authHelper as! OneDriveAuthHelper).authEntry,
                                                    .oneDrive)
                            let error = HiveError.failue(des: TOKEN_INVALID)
                            resolver.reject(error)
                            return
                        }
                        guard dataResponse.response?.statusCode == 200 else{
                            let error = HiveError.failue(des: jsonStr)
                            resolver.reject(error)
                            return
                        }
                        let data = dataResponse.data ?? Data()
                        resolver.fulfill(data)
                }
                }.catch { err in
                    let error = HiveError.failue(des: err.localizedDescription)
                    resolver.reject(error)
            }
        }
        return promise
    }

}
