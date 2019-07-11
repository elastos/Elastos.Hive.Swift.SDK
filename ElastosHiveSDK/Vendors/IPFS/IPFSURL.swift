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
internal var URL_POOL = [
    "http://52.83.119.110:9095",
    "http://52.83.159.189:9095",
    "http://3.16.202.140:9095",
    "http://18.217.147.205:9095",
    "http://18.219.53.133:9095"]
internal var validIp = 0

class IPFSURL {

    class func validURL() -> HivePromise<Void> {
        let promise = HivePromise<Void> { resolver in
            let uid = KeyChainStore.restoreUid(.hiveIPFS)
            if uid == "" {
                validUseNewUID(URL_POOL[validIp], { (url) in
                    if url == "" {
                        resolver.reject(HiveError.failue(des: "ALL URLS ARE INVALID"))
                    }else {
                        resolver.fulfill(Void())
                    }
                })
            }
            else {
                validUseStat(URL_POOL[validIp], uid, { (url) in
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

    class func validUseNewUID(_ url: String, _ result: @escaping (_ validUrl: String) -> Void) {

        var currentUrl = url
        let fullUrl = currentUrl + HIVE_SUB_Url.IPFS_UID_NEW.rawValue
        Alamofire.request(fullUrl,
                          method: .post,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: nil)
            .responseJSON { (dataResponse) in
                if dataResponse.response?.statusCode != 200 {
                    validIp += 1
                    if validIp > URL_POOL.count - 1 {
                        currentUrl = ""
                        validIp = 0
                        return
                    }
                    validUseNewUID(URL_POOL[validIp], result)
                }
                let json = JSON(dataResponse.result.value as Any)
                KeyChainStore.writebackForIpfs(.hiveIPFS, json["UID"].stringValue)
                result(currentUrl)
        }
    }

    class func validUseStat(_ url: String, _ uid: String, _ result: @escaping (_ validUrl: String) -> Void) {

        var currentUrl = url
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
                    if validIp > URL_POOL.count - 1 {
                        currentUrl = ""
                        validIp = 0
                        result(currentUrl)
                        return
                    }
                    validUseStat(URL_POOL[validIp], uid, result)
                    return
                }
                result(currentUrl)
            })
    }
}
