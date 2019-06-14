

import UIKit
import Alamofire

enum HIVE_SUB_Url: String {
    case IPFS_UID_NEW = "uid/new"
    case IPFS_UID_INFO = "uid/info"
    case IPFS_UID_LOGIN = "uid/login"
    case IPFS_FILES_CP = "files/cp"
    case IPFS_FILES_FLUSH = "files/flush"
    case IPFS_FILES_LS = "files/ls"
    case IPFS_FILES_MKDIR = "files/mkdir"
    case IPFS_FILES_MV = "files/mv"
    case IPFS_FILES_READ = "files/read"
    case IPFS_FILES_RM = "files/rm"
    case IPFS_FILES_STAT = "files/stat"
    case IPFS_FILES_WRITE = "files/write"
    case IPFS_NAME_PUBLISH = "name/publish"
}

let KEYCHAIN_IPFS_UID  = "last_uid"
class HiveIpfsURL {
    static var URL_POOL = [
        "http://52.83.159.189:9095/api/v0/",
        "http://52.83.119.110:9095/api/v0/",
        "http://3.16.202.140:9095/api/v0/",
        "http://18.217.147.205:9095/api/v0/",
        "http://18.219.53.133:9095/api/v0/"]

    internal static let IPFS_NODE_API_BASE = HiveIpfsURL.URL_POOL[0]
    internal static let IPFS_NODE_API_VRESION = "http://52.83.159.189:9095/version"

    class func validURL() -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
            if uid == "" {
                validUseNewUID(IPFS_NODE_API_BASE, { (url) in
                    if url == "" {
                        resolver.reject(HiveError.failue(des: "ALL URLS ARE INVALID"))
                    }else {
                        URL_POOL =  URL_POOL.sorted { (first, last) -> Bool in
                            if url == first {
                                return true
                            }
                            return false
                        }
                        resolver.fulfill(true)
                    }
                })
            }
            else {
                validUseStat(IPFS_NODE_API_BASE, uid, { (url) in
                    if url == "" {
                        resolver.reject(HiveError.failue(des: "ALL URLS ARE INVALID"))
                    }else {
                        guard url == URL_POOL.first else{
                            URL_POOL =  URL_POOL.sorted { (first, last) -> Bool in
                                if url == first {
                                    return true
                                }
                                return false
                            }
                            resolver.fulfill(true)
                            return
                        }
                        resolver.fulfill(true)
                    }
                })
            }
        }
        return promise
    }

    class func validUseNewUID(_ url: String, _ result: @escaping (_ validUrl: String) -> Void) {
        var i = 0
        var currentUrl = url
        let fullUrl = currentUrl + HIVE_SUB_Url.IPFS_UID_NEW.rawValue
        Alamofire.request(fullUrl,
                          method: .post,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: nil)
            .responseJSON { (dataResponse) in
                if dataResponse.response?.statusCode != 200 {
                    i += 1
                    if i > URL_POOL.count - 1 {
                        currentUrl = ""
                        return
                    }
                    validUseNewUID(URL_POOL[i], result)
                }
                result(currentUrl)
        }
    }

    class func validUseStat(_ url: String, _ uid: String, _ result: @escaping (_ validUrl: String) -> Void) {

        var i = 0
        var currentUrl = url
        let fullUrl = currentUrl + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
        let param = ["uid": uid,"path": "/"]
        Alamofire.request(fullUrl,
                          method: .post,
                          parameters: param,
                          encoding: URLEncoding.queryString,
                          headers: nil)
            .responseJSON(completionHandler: { (dataResponse) in
                if dataResponse.response?.statusCode != 200 {
                    i += 1
                    if i > URL_POOL.count - 1 {
                        currentUrl = ""
                        return
                    }
                    validUseStat(URL_POOL[i], uid, result)
                }
                result(currentUrl)
            })
    }

}


