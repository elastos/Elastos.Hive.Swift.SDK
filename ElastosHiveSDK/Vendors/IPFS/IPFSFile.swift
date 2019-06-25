import Foundation
import Alamofire

@inline(__always) private func TAG() -> String { return "IPFSFile" }

@objc(IPFSFile)
internal class IPFSFile: HiveFileHandle {
    var cursor: UInt64 = 0
    var finish: Bool = false

    override init(_ info: HiveFileInfo, _ authHelper: AuthHelper) {
        super.init(info, authHelper)
    }

    override func parentPathName() -> String {
        return HelperMethods.prePath(self.pathName)
    }

    override func lastUpdatedInfo() -> HivePromise<HiveFileInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>) -> HivePromise<HiveFileInfo> {
        let promise = HivePromise<HiveFileInfo> { resolver in
            _ = self.authHelper!.checkExpired().done({ (success) in

                let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
                let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
                let params = ["uid": uid, "path": self.pathName]
                Alamofire.request(url,
                                  method: .post,
                                  parameters: params,
                                  encoding: URLEncoding.queryString,
                                  headers: nil)
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else {
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "lastUpdatedInfo falied: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        Log.d(TAG(), "lastUpdatedInfo succeed")
                        let dic = [HiveFileInfo.itemId: uid]
                        let fileInfo = HiveFileInfo(dic)
                        self.lastInfo = fileInfo
                        handleBy.didSucceed(fileInfo)
                        resolver.fulfill(fileInfo)
                    })
            }).catch({ (error) in
                let error = HiveError.failue(des: error.localizedDescription)
                Log.e(TAG(), "lastUpdatedInfo falied: %s", error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return promise
    }

    override func moveTo(newPath: String) -> HivePromise<Bool> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            self.authHelper!.checkExpired().then({ (succeed) -> HivePromise<Bool> in
                return IPFSAPIs.moveTo(self.pathName, newPath)
            }).then({ (succeed) -> HivePromise<Bool> in
                return IPFSAPIs.publish(newPath)
            }).done({ (success) in
                Log.d(TAG(), "moveTo succeed")
                resolver.fulfill(true)
                handleBy.didSucceed(true)
            }).catch({ (error) in
                let hiveError = HiveError.failue(des: error.localizedDescription)
                Log.e(TAG(), "moveTo falied: %s", error.localizedDescription)
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
            self.authHelper!.checkExpired().then({ (succeed) -> HivePromise<Bool> in
                return IPFSAPIs.copyTo(self.pathName, newPath)
            }).then({ (success) -> HivePromise<Bool> in
                return IPFSAPIs.publish(newPath)
            }).done({ (success) in
                Log.d(TAG(), "copyTo succeed")
                resolver.fulfill(true)
                handleBy.didSucceed(true)
            }).catch({ (error) in
                let hiveError = HiveError.failue(des: error.localizedDescription)
                Log.e(TAG(), "copyTo falied: %s", error.localizedDescription)
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
            self.authHelper!.checkExpired().then({ (succeed) -> HivePromise<Bool> in
                return IPFSAPIs.deleteItem(self.pathName)
            }).then({ (success) -> HivePromise<Bool> in
                return IPFSAPIs.publish("/")
            }).done({ (success) in
                Log.d(TAG(), "deleteItem succeed")
                resolver.fulfill(success)
                handleBy.didSucceed(success)
            }).catch({ (error) in
                let hiveError = HiveError.failue(des: error.localizedDescription)
                Log.e(TAG(), "deleteItem falied: %s", error.localizedDescription)
                resolver.reject(hiveError)
                handleBy.runError(hiveError)
            })
        }
        return promise
    }

    override func readData() -> HivePromise<Data> {
        return readData(handleBy: HiveCallback<Data>())
    }

    override func readData(handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let promise = HivePromise<Data>{ resolver in
            //todo
        }
        return promise
    }

    override func readData(_ position: UInt64) -> HivePromise<Data> {
       return readData(position, handleBy: HiveCallback<Data>())
    }

    override func readData(_ position: UInt64, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let promise = HivePromise<Data>{ resolver in
            // todo
        }
        return promise
    }

    override func writeData(withData: Data) -> HivePromise<Int32> {
        return writeData(withData: withData, handleBy: HiveCallback<Int32>())
    }

    override func writeData(withData: Data, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let promise = HivePromise<Int32>{ resolver in
            // todo
        }
        return promise
    }

    override func writeData(withData: Data, _ position: UInt64) -> HivePromise<Int32> {
        return writeData(withData: withData, position, handleBy: HiveCallback<Int32>())
    }

    override func writeData(withData: Data, _ position: UInt64, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let promise = HivePromise<Int32> { resolver in
            // todo
        }
        return promise
    }

/*
    override func writeData(withData: Data) -> HivePromise<Bool> {
        return writeData(withData: withData, handleBy: HiveCallback<Bool>())
    }

    override func writeData(withData: Data, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {

        let promise = HivePromise<Bool> { resolver in
            self.authHelper!.checkExpired().then({ (succeed) -> HivePromise<Bool> in
                return IPFSAPIs.writeData(self.pathName, withData)
            }).then({ (success) -> HivePromise<Bool> in
                return IPFSAPIs.publish(self.pathName)
            }).done({ (success) in
                Log.d(TAG(), "writeData succeed")
                resolver.fulfill(true)
                handleBy.didSucceed(true)
            }).catch({ (error) in
                let hiveError = HiveError.failue(des: error.localizedDescription)
                Log.e(TAG(), "writeData falied: %s", error.localizedDescription)
                resolver.reject(hiveError)
                handleBy.runError(hiveError)
            })
        }
        return promise
    }

    override func readData() -> HivePromise<String> {
        return readData(handleBy: HiveCallback<String>())
    }

    override func readData(handleBy: HiveCallback<String>) -> HivePromise<String> {
        let promise = HivePromise<String> { resolver in
            _ = self.authHelper!.checkExpired().done({ (success) in

                let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue
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
                            Log.e(TAG(), "readData falied: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        Log.d(TAG(), "readData succeed")
                        let data = dataResponse.data
                        let content: String = String(data: data!, encoding: .utf8) ?? ""
                        resolver.fulfill(content)
                        handleBy.didSucceed(content)
                    })
            }).catch({ (error) in
                let error = HiveError.failue(des: error.localizedDescription)
                Log.e(TAG(), "readData falied: %s", error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return promise
    }
 */
}
