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
internal var isValid: Bool = false

class IPFSURL {
    class func validURL(_ parameter: IPFSParameter) -> HivePromise<Void> {
        let promise: HivePromise = HivePromise<Void> { resolver in
            guard !isValid else {
                resolver.fulfill(Void())
                return
            }
            validUseVersion(parameter, { succeed in
                resolver.fulfill(Void())
            })
        }
        return promise
    }

    class func validUseVersion(_ parameter: IPFSParameter, _ result: @escaping (_ re: Bool) -> Void) {
        if validIp >= parameter.entry.rpcAddrs.count {
            validIp = 0
        }
        let currentUrl = parameter.entry.rpcAddrs[validIp]
        let fullUrl = currentUrl + HIVE_SUB_Url.IPFS_VERSION.rawValue
        Alamofire.request(fullUrl,
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: nil)
            .responseJSON { (dataResponse) in
                if dataResponse.response?.statusCode == 404 || dataResponse.response?.statusCode == NSURLErrorTimedOut {
                    isValid = false
                    validIp = validIp + 1
                    if validIp > parameter.entry.rpcAddrs.count - 1 {
                        validIp = 0
                    }
                    validUseVersion(parameter, result)
                    return
                }
                isValid = true
                result(true)
        }
    }

}
