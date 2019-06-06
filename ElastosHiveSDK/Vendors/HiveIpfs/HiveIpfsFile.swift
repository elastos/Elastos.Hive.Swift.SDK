import Foundation
import Alamofire

@objc(HiveIpfsFile)
internal class HiveIpfsFile: HiveFileHandle {

    override init(_ info: HiveFileInfo, _ authHelper: AuthHelper) {
        super.init(info, authHelper)
    }

    override func parentPathName() -> String {
        return "TODO"
    }

    override func lastUpdatedInfo() -> HivePromise<HiveFileInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>) -> HivePromise<HiveFileInfo> {
        let promise = HivePromise<HiveFileInfo> { resolver in
            _ = "TODO"
        }
        return promise
    }

    override func moveTo(newPath: String) -> HivePromise<Bool> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            HiveIpfsApis.moveTo(self.pathName, newPath).then({ (success) -> HivePromise<Bool> in
                return HiveIpfsApis.publish(newPath)
            }).done({ (success) in
                resolver.fulfill(true)
                handleBy.didSucceed(true)
            }).catch({ (error) in
                let hiveError = HiveError.failue(des: error.localizedDescription)
                resolver.reject(hiveError)
                handleBy.runError(hiveError)
            })
        }
        return promise
    }

    override func copyTo(newPath: String) -> HivePromise<Bool> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            HiveIpfsApis.copyTo(self.pathName, newPath).then({ (success) -> HivePromise<Bool> in
                return HiveIpfsApis.publish(newPath)
            }).done({ (success) in
                resolver.fulfill(true)
                handleBy.didSucceed(true)
            }).catch({ (error) in
                let hiveError = HiveError.failue(des: error.localizedDescription)
                resolver.reject(hiveError)
                handleBy.runError(hiveError)
            })
        }
        return promise
    }

    override func deleteItem() -> HivePromise<Bool> {
        return deleteItem(handleBy: HiveCallback<Bool>())
    }

    override func deleteItem(handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            HiveIpfsApis.deleteItem(self.pathName).then({ (success) -> HivePromise<Bool> in
                return HiveIpfsApis.publish("/")
            }).done({ (success) in
                resolver.fulfill(success)
            }).catch({ (error) in
                let hiveError = HiveError.failue(des: error.localizedDescription)
                resolver.reject(hiveError)
                handleBy.runError(hiveError)
            })
        }
        return promise
    }

    override func writeData(withData: Data) -> HivePromise<Bool> {
        return writeData(withData: withData, handleBy: HiveCallback<Bool>())
    }

    override func writeData(withData: Data, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {

        let promise = HivePromise<Bool> { resolver in
            let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
            let params = ["uid": uid, "path": self.pathName, "file": "file", "create": "true"]
            let url = HiveIpfsURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_WRITE.rawValue + "?" + params.queryString
            Alamofire.upload(multipartFormData: { (data) in
                data.append(withData, withName: "file", fileName: "file", mimeType: "text/plain")
            }, to: url, encodingCompletion: { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else {
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            handleBy.runError(error)
                            resolver.reject(error)
                            return
                        }
                        handleBy.didSucceed(true)
                        resolver.fulfill(true)
                    })
                    break
                case .failure(let error):
                    let error = HiveError.failue(des: error.localizedDescription)
                    handleBy.runError(error)
                    resolver.reject(error)
                    break
                }
            })
        }
        return promise
    }

    override func readData() -> HivePromise<String> {
        return readData(handleBy: HiveCallback<String>())
    }

    override func readData(handleBy: HiveCallback<String>) -> HivePromise<String> {
        let promise = HivePromise<String> { resolver in
            let url = HiveIpfsURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_READ.rawValue
            let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
            let param = ["uid": uid, "path": self.pathName]
            Alamofire.request(url,
                              method: .post,
                              parameters: param,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.response?.statusCode == 200 else {
                        let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                        resolver.reject(error)
                        handleBy.runError(error)
                        return
                    }
                    let data = dataResponse.data
                    let content: String = String(data: data!, encoding: .utf8) ?? ""
                    resolver.fulfill(content)
                    handleBy.didSucceed(content)
                })
        }
        return promise
    }
    
}
