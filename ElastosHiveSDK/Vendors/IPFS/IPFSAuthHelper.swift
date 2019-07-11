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

    override func loginAsync(_ authenticator: Authenticator) -> HivePromise<Void> {
        return loginAsync(authenticator, handleBy: HiveCallback<Void>())
    }

    override func loginAsync(_ authenticator: Authenticator, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let promise = HivePromise<Void> { resolver in
            self.checkExpired().then { padding -> HivePromise<String> in
                return self.getUID(self)
                }.then { (uid) -> HivePromise<String> in
                    return self.getPeerId(uid)
                }.then { (peerId) -> HivePromise<String> in
                    return self.getHash(peerId)
                }.then { (hash) -> HivePromise<Void> in
                    return self.logIn(hash)
                }.done { padding in
                    let padding = Void();
                    resolver.fulfill(padding)
                    Log.d(TAG(), "login succeed")
                }.catch { (error) in
                    resolver.reject(error)
                    Log.e(TAG(), "login falied: " + HiveError.des(error as! HiveError))
            }
        }
        return promise
    }

    override func logoutAsync() -> HivePromise<Void> {
        return logoutAsync(handleBy: HiveCallback<Void>())
    }

    override func logoutAsync(handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let error = HiveError.failue(des: "TODO")
        return HivePromise<Void>(error: error)
    }

    override func checkExpired() -> HivePromise<Void> {
        return IPFSURL.validURL()
    }

    private func getUID(_ authHelper: AuthHelper) -> HivePromise<String> {
        let uid = KeyChainStore.restoreUid(.hiveIPFS)
        guard uid == "" else {
            let promise = HivePromise<String> { resolver in
                resolver.fulfill(uid)
            }
            return promise
        }
        let promise = HivePromise<String> { resolver in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_UID_NEW.rawValue
            IPFSAPIs.request(url, .post, nil)
                .done { jsonData in
                    let uid = jsonData["uid"].stringValue
                    resolver.fulfill(uid)
                }
                .catch { error in
                    let error = HiveError.failue(des: HiveError.des(error as! HiveError))
                    resolver.reject(error)
            }
        }
        return promise
    }

    private func getPeerId(_ uid: String) -> HivePromise<String> {
        let promise = HivePromise<String> { resolver in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_UID_INFO.rawValue
            let param = ["uid": uid]
            IPFSAPIs.request(url, .post, param)
                .done{ jsonData in
                    let peerId = jsonData["PeerID"].stringValue
                    resolver.fulfill(peerId)
                }
                .catch{ error in
                    let error = HiveError.failue(des: HiveError.des(error as! HiveError))
                    resolver.reject(error)
            }
        }
        return promise
    }

    private func getHash(_ peerId: String) -> HivePromise<String> {
        let promise = HivePromise<String> { resolver in
            let url = URL_POOL[validIp] + "/api/v0/name/resolve" + "?" + "arg=" + peerId
            IPFSAPIs.request(url, .get, nil)
                .done{ jsonData in
                    let hash = jsonData["Path"].stringValue
                    resolver.fulfill(hash)
                }
                .catch{ error in
                    let errorMessage = HiveError.des(error as! HiveError)
                    if errorMessage == "routing: not found" {
                        IPFSAPIs.getHash("/", self)
                            .then{ hash -> HivePromise<Void> in
                                IPFSAPIs.publish(hash, self)
                            }.done{ void  in
                                self.getHash(peerId)
                                    .done{ hash in
                                        resolver.fulfill(hash)
                                    }.catch{ error in
                                        resolver.reject(error)
                                }
                            }.catch{ error in
                                resolver.reject(error)
                        }
                    }

            }
        }
        return promise
    }

    private func logIn(_ hash: String) -> HivePromise<Void> {
        let promise = HivePromise<Void> { resolver in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_UID_LOGIN.rawValue
            let uid = KeyChainStore.restoreUid(.hiveIPFS)
            param.uid = uid
            let param = ["uid": uid, "hash": hash]
            IPFSAPIs.request(url, .post, param)
                .done{ json in
                    resolver.fulfill(Void())
                }
                .catch{ error in
                    let error = HiveError.failue(des: HiveError.des(error as! HiveError))
                    resolver.reject(error)
            }
        }
        return promise
    }

}
