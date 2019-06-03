

import UIKit
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
            let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
            self.getHash(uid, "/").done({ (hash) in
                let url = "http://52.83.159.189:9095/api/v0/uid/login"
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
            }).catch({ (error) in
                let error = HiveError.failue(des: error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            })
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

    private func getHash(_ uid: String, _ path: String) -> HivePromise<String> {
        let promise = HivePromise<String> { resolver in
            let url = "http://52.83.159.189:9095/api/v0/files/stat"
            let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
            let param = ["uid": uid, "path": "/"]
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
                    let jsonData = JSON(dataResponse.result.value as Any)
                    let hash = jsonData["Hash"].stringValue
                    self.saveIpfsAcount(uid)
                    resolver.fulfill(hash)
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
