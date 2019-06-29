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
        return ConvertHelper.prePath(self.pathName)
    }

    override func lastUpdatedInfo() -> HivePromise<HiveFileInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>) -> HivePromise<HiveFileInfo> {
        let promise = HivePromise<HiveFileInfo> { resolver in
            _ = self.authHelper.checkExpired().done({ (success) in

                let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
                let uid = KeyChainStore.restoreUid(.hiveIPFS)
                let params = ["uid": uid, "path": self.pathName]
                Alamofire.request(url,
                                  method: .post,
                                  parameters: params,
                                  encoding: URLEncoding.queryString,
                                  headers: nil)
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else {
                            let error = HiveError.failue(des: ConvertHelper.jsonToString(dataResponse.data!))
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

    override func moveTo(newPath: String) -> HivePromise<HiveVoid> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<HiveVoid>())
    }

    override func moveTo(newPath: String, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            self.authHelper.checkExpired().then({ (succeed) -> HivePromise<HiveVoid> in
                return IPFSAPIs.moveTo(self.pathName, newPath)
            }).then({ (succeed) -> HivePromise<HiveVoid> in
                return IPFSAPIs.publish(newPath)
            }).done({ (success) in
                Log.d(TAG(), "moveTo succeed")
                resolver.fulfill(HiveVoid())
                handleBy.didSucceed(HiveVoid())
            }).catch({ (error) in
                let hiveError = HiveError.failue(des: error.localizedDescription)
                Log.e(TAG(), "moveTo falied: %s", error.localizedDescription)
                resolver.reject(hiveError)
                handleBy.runError(hiveError)
            })
        }
        return promise
    }

    override func copyTo(newPath: String) -> HivePromise<HiveVoid> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<HiveVoid>())
    }

    override func copyTo(newPath: String, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            self.authHelper.checkExpired().then({ (succeed) -> HivePromise<HiveVoid> in
                return IPFSAPIs.copyTo(self.pathName, newPath)
            }).then({ (success) -> HivePromise<HiveVoid> in
                return IPFSAPIs.publish(newPath)
            }).done({ (success) in
                Log.d(TAG(), "copyTo succeed")
                resolver.fulfill(HiveVoid())
                handleBy.didSucceed(HiveVoid())
            }).catch({ (error) in
                let hiveError = HiveError.failue(des: error.localizedDescription)
                Log.e(TAG(), "copyTo falied: %s", error.localizedDescription)
                resolver.reject(hiveError)
                handleBy.runError(hiveError)
            })
        }
        return promise
    }

    override func deleteItem() -> HivePromise<HiveVoid> {
        return deleteItem(handleBy: HiveCallback<HiveVoid>())
    }

    override func deleteItem(handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            self.authHelper.checkExpired().then({ (succeed) -> HivePromise<HiveVoid> in
                return IPFSAPIs.deleteItem(self.pathName)
            }).then({ (success) -> HivePromise<HiveVoid> in
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

    override func readData(_ length: Int) -> HivePromise<Data> {
        return readData(length, handleBy: HiveCallback<Data>())
    }

    override func readData(_ length: Int, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let promise = HivePromise<Data> { resolver in
            if finish == true {
                Log.e(TAG(), "The file has been read finished")
                resolver.fulfill(Data())
                handleBy.didSucceed(Data())
                return
            }
            let uid = KeyChainStore.restoreUid(.hiveIPFS)
            let url: String = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue + "?uid=" + uid + "&path=" + self.pathName
            let cachePath = url.md5
            let file = CacheHelper.checkCacheFileIsExist(.hiveIPFS, cachePath)
            if file {
                let data: Data = CacheHelper.readCache(.hiveIPFS, cachePath, cursor, length)
                cursor += UInt64(data.count)
                resolver.fulfill(data)
                handleBy.didSucceed(data)
                if data.count == 0 {
                    cursor = 0
                    finish = true
                }
                return
            }
            self.getRemoteFile(url, { (data, error) in
                guard error == nil else {
                    Log.e(TAG(), "readData falied: %s", error!.localizedDescription)
                    resolver.reject(error!)
                    handleBy.runError(error!)
                    return
                }
                let isSuccess = CacheHelper.saveCache(.hiveIPFS, cachePath, data: data!)
                var readData = Data()
                if isSuccess {
                    readData = CacheHelper.readCache(.hiveIPFS, cachePath, self.cursor, length)
                }
                self.cursor += UInt64(readData.count)
                Log.d(TAG(), "readData succeed")
                resolver.fulfill(readData)
                handleBy.didSucceed(readData)
            })
        }
        return promise
    }

    override func readData(_ length: Int, _ position: UInt64) -> HivePromise<Data> {
       return readData(length, position, handleBy: HiveCallback<Data>())
    }

    override func readData(_ length: Int, _ position: UInt64, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let promise = HivePromise<Data> { resolver in
            let uid = KeyChainStore.restoreUid(.hiveIPFS)
            let url: String = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue + "?uid=" + uid + "&path=" + self.pathName
            let cachePath = url.md5
            let file = CacheHelper.checkCacheFileIsExist(.hiveIPFS, cachePath)
            if file {
                let data = CacheHelper.readCache(.hiveIPFS, cachePath, position, length)
                cursor += UInt64(data.count)
                resolver.fulfill(data)
                handleBy.didSucceed(data)
                return
            }
            self.getRemoteFile(url, { (data, error) in
                guard error == nil else {
                    Log.e(TAG(), "readData falied: %s", error!.localizedDescription)
                    resolver.reject(error!)
                    handleBy.runError(error!)
                    return
                }
                let isSuccess = CacheHelper.saveCache(.hiveIPFS, cachePath, data: data!)
                var readData = Data()
                if isSuccess {
                    readData = CacheHelper.readCache(.hiveIPFS, cachePath, position, length)
                    self.cursor += UInt64(readData.count)
                }
                Log.d(TAG(), "readData succeed")
                resolver.fulfill(readData)
                handleBy.didSucceed(readData)
            })
        }
        return promise
    }

    override func writeData(withData: Data) -> HivePromise<Int32> {
        return writeData(withData: withData, handleBy: HiveCallback<Int32>())
    }

    override func writeData(withData: Data, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let promise = HivePromise<Int32> { resolver in
            let uid = KeyChainStore.restoreUid(.hiveIPFS)
            let url: String = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue + "?uid=" + uid + "&path=" + self.pathName
            let cachePath = url.md5
            let file = CacheHelper.checkCacheFileIsExist(.hiveIPFS, cachePath)
            if file {
                let length = CacheHelper.writeCache(.hiveIPFS, cachePath, data: withData, cursor)
                cursor += UInt64(length)
                resolver.fulfill(length)
                handleBy.didSucceed(length)
                return
            }
            self.getRemoteFile(url, { (data, error) in
                guard error == nil else {
                    Log.e(TAG(), "writeData falied: %s", error!.localizedDescription)
                    resolver.reject(error!)
                    handleBy.runError(error!)
                    return
                }
                _ = CacheHelper.saveCache(.hiveIPFS, cachePath, data: data!)
                let length = CacheHelper.writeCache(.hiveIPFS, cachePath, data: withData, self.cursor)
                self.cursor += UInt64(length)
                Log.d(TAG(), "writeData succeed")
                resolver.fulfill(length)
                handleBy.didSucceed(length)
            })
        }
        return promise
    }

    override func writeData(withData: Data, _ position: UInt64) -> HivePromise<Int32> {
        return writeData(withData: withData, position, handleBy: HiveCallback<Int32>())
    }

    override func writeData(withData: Data, _ position: UInt64, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let promise = HivePromise<Int32> { resolver in
            let uid = KeyChainStore.restoreUid(.hiveIPFS)
            let url: String = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue + "?uid=" + uid + "&path=" + self.pathName
            let cachePath = url.md5
            let file = CacheHelper.checkCacheFileIsExist(.hiveIPFS, cachePath)
            if file {
                let length = CacheHelper.writeCache(.hiveIPFS, cachePath, data: withData, position)
                cursor += UInt64(length)
                resolver.fulfill(length)
                handleBy.didSucceed(length)
                return
            }
            self.getRemoteFile(url, { (data, error) in
                guard error == nil else {
                    Log.e(TAG(), "writeData falied: %s", error!.localizedDescription)
                    resolver.reject(error!)
                    handleBy.runError(error!)
                    return
                }
                _ = CacheHelper.saveCache(.hiveIPFS, cachePath, data: data!)
                let length = CacheHelper.writeCache(.hiveIPFS, cachePath, data: withData, position)
                self.cursor += UInt64(length)
                Log.d(TAG(), "writeData succeed")
                resolver.fulfill(length)
                handleBy.didSucceed(length)
            })
        }
        return promise
    }

    override func commitData() -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            let uid = KeyChainStore.restoreUid(.hiveIPFS)
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue + "?uid=" + uid + "&path=" + self.pathName
            let data = CacheHelper.uploadFile(.hiveIPFS, url.md5)
            self.authHelper.checkExpired().then({ (succeed) -> HivePromise<HiveVoid> in
                return IPFSAPIs.writeData(self.pathName, data)
            }).then({ (success) -> HivePromise<HiveVoid> in
                return IPFSAPIs.publish(self.pathName)
            }).done({ (success) in
                CacheHelper.uploadCache(.hiveIPFS, url.md5)
                Log.d(TAG(), "writeData succeed")
                resolver.fulfill(HiveVoid())
            }).catch({ (error) in
                let hiveError = HiveError.failue(des: error.localizedDescription)
                Log.e(TAG(), "writeData falied: %s", error.localizedDescription)
                resolver.reject(hiveError)
            })
        }
        return promise
    }

    override func discardData() {
        cursor = 0
        finish = false
        let uid = KeyChainStore.restoreUid(.hiveIPFS)
        let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue + "?uid=" + uid + "&path=" + self.pathName
        _ = CacheHelper.discardCache(.hiveIPFS, url.md5)
    }

    override func close() {
        cursor = 0
        finish = false
    }

    private func getRemoteFile(_ url: String, _ fileResult: @escaping (_ data: Data?, _ error: HiveError?) -> Void) {
        _ = self.authHelper.checkExpired().done { result in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue
            let uid = KeyChainStore.restoreUid(.hiveIPFS)
            let param = ["uid": uid, "path": self.pathName]
            Alamofire.request(url,
                              method: .post,
                              parameters: param,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.response?.statusCode == 200 else {
                        let error = HiveError.failue(des: ConvertHelper.jsonToString(dataResponse.data!))
                        Log.e(TAG(), "readData falied: %s", error.localizedDescription)
                        fileResult(nil, error)
                        return
                    }
                    Log.d(TAG(), "readData succeed")
                    let data = dataResponse.data
                    fileResult(data, nil)
                })
            }.catch { err in
                let error = HiveError.failue(des: err.localizedDescription)
                fileResult(nil, error)
        }
    }
}
