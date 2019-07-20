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
import Alamofire

internal enum HIVE_SUB_Url: String {
    case IPFS_UID_NEW = "/api/v0/uid/new"
    case IPFS_UID_INFO = "/api/v0/uid/info"
    case IPFS_UID_LOGIN = "/api/v0/uid/login"
    case IPFS_FILES_CP = "/api/v0/files/cp"
    case IPFS_FILES_FLUSH = "/api/v0/files/flush"
    case IPFS_FILES_LS = "/api/v0/files/ls"
    case IPFS_FILES_MKDIR = "/api/v0/files/mkdir"
    case IPFS_FILES_MV = "/api/v0/files/mv"
    case IPFS_FILES_READ = "/api/v0/files/read"
    case IPFS_FILES_RM = "/api/v0/files/rm"
    case IPFS_FILES_STAT = "/api/v0/files/stat"
    case IPFS_FILES_WRITE = "/api/v0/files/write"
    case IPFS_NAME_PUBLISH = "/api/v0/name/publish"
    case IPFS_VERSION = "/version"
}
internal let KEYCHAIN_IPFS_UID  = "last_uid"
internal var validIp = 0

class IPFSURL {

    class func validURL(_ parameter: IPFSParameter) -> HivePromise<Void> {
        let promise: HivePromise = HivePromise<Void> { resolver in
            let uid = KeyChainStore.restoreUid(.hiveIPFS)
            if uid == "" {
                validUseNewUID(parameter, { (url) in
                    if url == "" {
                        resolver.reject(HiveError.failue(des: "ALL URLS ARE INVALID"))
                    }else {
                        resolver.fulfill(Void())
                    }
                })
            }
            else {
                validUseStat(parameter, { (url) in
                    if url == "" {
                        resolver.reject(HiveError.failue(des: "ALL URLS ARE INVALID"))
                    }else {
                        resolver.fulfill(Void())
                    }
                })
            }
        }
        return promise
    }

    class func validUseNewUID(_ parameter: IPFSParameter, _ result: @escaping (_ validUrl: String) -> Void) {

        var currentUrl = parameter.entry.rpcAddrs[validIp]
        let fullUrl = currentUrl + HIVE_SUB_Url.IPFS_UID_NEW.rawValue
        Alamofire.request(fullUrl,
                          method: .post,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: nil)
            .responseJSON { (dataResponse) in
                if dataResponse.response?.statusCode != 200 {
                    validIp += 1
                    if validIp > parameter.entry.rpcAddrs.count - 1 {
                        currentUrl = ""
                        validIp = 0
                        return
                    }
                    validUseNewUID(parameter, result)
                }
                let json = JSON(dataResponse.result.value as Any)
                KeyChainStore.writebackForIpfs(.hiveIPFS, json["UID"].stringValue)
                result(currentUrl)
        }
    }

    class func validUseStat(_ parameter: IPFSParameter, _ result: @escaping (_ validUrl: String) -> Void) {

        var currentUrl = parameter.entry.rpcAddrs[validIp]
        let uid = parameter.entry.uid
        let fullUrl = currentUrl + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
        let param = ["uid": uid,"path": "/"]
        Alamofire.request(fullUrl,
                          method: .post,
                          parameters: param,
                          encoding: URLEncoding.queryString,
                          headers: nil)
            .responseJSON(completionHandler: { (dataResponse) in
                if dataResponse.response?.statusCode != 200 || dataResponse.result.isFailure {
                    validIp += 1
                    if validIp > parameter.entry.rpcAddrs.count - 1 {
                        currentUrl = ""
                        validIp = 0
                        result(currentUrl)
                        return
                    }
                    validUseStat(parameter, result)
                    return
                }
                result(currentUrl)
            })
    }
}
