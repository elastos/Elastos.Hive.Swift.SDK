

import Foundation
import Alamofire
import PromiseKit

@inline(__always) private func TAG() -> String { return "HiveIpfsAuthHelper" }

class HiveIpfsAuthHelper: AuthHelper {
    let param: HiveIpfsParameter

    init(_ param: HiveIpfsParameter) {
        self.param = param
        super.init()
    }

    override func loginAsync(_ authenticator: Authenticator) -> HivePromise<Bool> {
        return loginAsync(authenticator, handleBy: HiveCallback<Bool>())
    }

    override func loginAsync(_ authenticator: Authenticator, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            self.getUID().then { (uid) -> HivePromise<String> in
                return self.getPeerId(uid)
                }.then { (peerId) -> HivePromise<String> in
                    return self.getHash(peerId)
                }.then { (hash) -> HivePromise<Bool> in
                    return self.logIn(hash)
                }.done { (success) in
                    resolver.fulfill(success)
                }.catch { (error) in
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func logoutAsync() -> HivePromise<Bool> {
        return logoutAsync(handleBy: HiveCallback<Bool>())
    }

    override func logoutAsync(handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "TODO")
        return HivePromise<Bool>(error: error)
    }

    private func getUID() -> HivePromise<String> {
        let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
        guard uid == "" else {
            let promise = HivePromise<String> { resolver in
                resolver.fulfill(uid)
            }
            return promise
        }
        let promise = HivePromise<String> { resolver in
            let url = HiveIpfsURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_UID_NEW.rawValue
            Alamofire.request(url,
                              method: .post,
                              parameters: nil,
                              encoding: JSONEncoding.default,
                              headers: nil)
                .responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.response?.statusCode == 200 else {
                        let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                        resolver.reject(error)
                        return
                    }
                    let jsonData = JSON(dataResponse.result.value as Any)
                    let uid = jsonData["uid"].stringValue
                    self.saveIpfsAcount(uid)
                    resolver.fulfill(uid)
                })
        }
        return promise
    }

    private func getPeerId(_ uid: String) -> HivePromise<String> {
        let promise = HivePromise<String> { resolver in
            let url = HiveIpfsURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_UID_INFO.rawValue
            let param = ["uid": uid]
            Alamofire.request(url,
                              method: .post,
                              parameters: param,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.response?.statusCode == 200 else {
                        let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                        resolver.reject(error)
                        return
                    }
                    let jsonData = JSON(dataResponse.result.value as Any)
                    let peerId = jsonData["PeerID"].stringValue
                    resolver.fulfill(peerId)
                })
        }
        return promise
    }

    private func getHash(_ peerId: String) -> HivePromise<String> {
        let promise = HivePromise<String> { resolver in
            let url = HiveIpfsURL.IPFS_NODE_API_BASE + "name/resolve"
            let param = ["arg": peerId]
            Alamofire.request(url,
                              method: .post,
                              parameters: param,
                              encoding: JSONEncoding.default,
                              headers: nil)
                .responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.response?.statusCode == 200 else {
                        let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                        resolver.reject(error)
                        return
                    }
                    let jsonData = JSON(dataResponse.result.value as Any)
                    let hash = jsonData["Path"].stringValue
                    resolver.fulfill(hash)
                })
        }
        return promise
    }

    private func logIn(_ hash: String) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            let url = HiveIpfsURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_UID_LOGIN.rawValue
            let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
            let param = ["uid": uid, "hash": hash]
            Alamofire.request(url,
                              method: .post,
                              parameters: param,
                              encoding: URLEncoding.queryString, headers: nil)
                .responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.response?.statusCode == 200 else{
                        let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                        resolver.reject(error)
                        return
                    }
                    resolver.fulfill(true)
                })
        }
        return promise
    }

    private func saveIpfsAcount(_ uid: String){
        let hiveIpfsAccountJson = [KEYCHAIN_IPFS_UID: uid]
        HelperMethods.saveKeychain(.IPFSACCOUNT, hiveIpfsAccountJson)
    }

    private func removeIpfsAcount(){
        let hiveIpfsAccountJson = [KEYCHAIN_IPFS_UID: ""]
        HelperMethods.saveKeychain(.IPFSACCOUNT, hiveIpfsAccountJson)
    }

}
