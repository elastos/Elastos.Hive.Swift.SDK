

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

let KEYCHAIN_IPFS_UID  = "uid"
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

            let validId = URL_POOL.filter({ (ip) -> Bool in
                let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
                if uid == "" {
                    return (validUseNewUID(ip).result != nil)
                }else {
                    return (validUseStat(ip, uid).result != nil)
                }
            }).first

            if validId != nil {
                URL_POOL =  URL_POOL.sorted { (first, last) -> Bool in
                    if validId == first {
                        return true
                    }
                    return false
                }
                resolver.fulfill(true)
            }
            else {
                let error = HiveError.failue(des: "ALL URLS ARE INVALID")
                print(error.localizedDescription)
                resolver.reject(error)
            }
        }
        return promise
    }

    class func validUseNewUID(_ ip: String) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            let url = ip + HIVE_SUB_Url.IPFS_UID_NEW.rawValue
            Alamofire.request(url,
                              method: .post,
                              parameters: nil,
                              encoding: JSONEncoding.default,
                              headers: nil)
                .responseJSON { (dataResponse) in
                    guard dataResponse.response?.statusCode == 200 else{
                        resolver.fulfill(false)
                        return
                    }
                    resolver.fulfill(true)
            }
        }
        return promise
    }

    class func validUseStat(_ ip: String, _ uid: String) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            let url = ip + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
            let param = ["uid": uid,"path": "/"]
            Alamofire.request(url,
                              method: .post,
                              parameters: param,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.response?.statusCode == 200 else{
                        resolver.fulfill(false)
                        return
                    }
                    resolver.fulfill(true)
                })
        }
        return promise
    }
}


