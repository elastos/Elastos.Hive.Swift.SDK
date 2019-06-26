import Foundation
import Alamofire
import PromiseKit

@inline(__always) private func TAG() -> String { return "IPFSAuthHelper" }

class IPFSAuthHelper: AuthHelper {
    let param: IPFSParameter

    init(_ param: IPFSParameter) {
        self.param = param
        super.init()
    }

    override func loginAsync(_ authenticator: Authenticator) -> HivePromise<HiveVoid> {
        return loginAsync(authenticator, handleBy: HiveCallback<HiveVoid>())
    }

    override func loginAsync(_ authenticator: Authenticator, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            self.checkExpired().then { padding -> HivePromise<String> in
                return self.getUID()
            }.then { (uid) -> HivePromise<String> in
                return self.getPeerId(uid)
            }.then { (peerId) -> HivePromise<String> in
                return self.getHash(peerId)
            }.then { (hash) -> HivePromise<Bool> in
                return self.logIn(hash)
            }.done { padding in
                let padding = HiveVoid();
                resolver.fulfill(padding)
                Log.d(TAG(), "login succeed")
            }.catch { (error) in
                resolver.reject(error)
                Log.e(TAG(), "login falied: %s", error.localizedDescription)
            }
        }
        return promise
    }

    override func logoutAsync() -> HivePromise<HiveVoid> {
        return logoutAsync(handleBy: HiveCallback<HiveVoid>())
    }

    override func logoutAsync(handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "TODO")
        return HivePromise<HiveVoid>(error: error)
    }

    override func checkExpired() -> HivePromise<HiveVoid> {
       //return IPFSURL.validURL()
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
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
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_UID_NEW.rawValue
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
                    resolver.fulfill(uid)
                })
        }
        return promise
    }

    private func getPeerId(_ uid: String) -> HivePromise<String> {
        let promise = HivePromise<String> { resolver in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_UID_INFO.rawValue
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
            let url = URL_POOL[validIp] + "/api/v0/name/resolve"
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
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_UID_LOGIN.rawValue
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
}
