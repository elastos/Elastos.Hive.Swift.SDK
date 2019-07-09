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
        return PathExtracter(pathName).dirNamePart()
    }

    override func lastUpdatedInfo() -> HivePromise<HiveFileInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>) -> HivePromise<HiveFileInfo> {
        let promise = HivePromise<HiveFileInfo> { resolver in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
            let uid = (self.authHelper as! IPFSAuthHelper).param.uid
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let params = ["uid": uid, "path": path]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, params)
                }
                .done{ jsonData in
                    Log.d(TAG(), "lastUpdatedInfo succeed")
                    let dic = [HiveFileInfo.itemId: uid,
                               HiveFileInfo.name: PathExtracter(self.pathName).baseNamePart(),
                               HiveFileInfo.size: String(jsonData["Size"].intValue)]
                    let fileInfo = HiveFileInfo(dic)
                    self.lastInfo = fileInfo
                    handleBy.didSucceed(fileInfo)
                    resolver.fulfill(fileInfo)
                }
                .catch{ error in
                    Log.e(TAG(), "lastUpdatedInfo falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }

    override func moveTo(newPath: String) -> HivePromise<HiveVoid> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<HiveVoid>())
    }

    override func moveTo(newPath: String, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_MV.rawValue
            let uid = (authHelper as! IPFSAuthHelper).param.uid
            let originPath = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let dest = newPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let params = ["uid": uid, "source": originPath, "dest": dest]

            self.authHelper.checkExpired().then{ void -> HivePromise<JSON> in
                return IPFSAPIs.request(url, .post, params)
                }.then{ json -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper)
                }.then{ hash -> HivePromise<HiveVoid> in
                    return IPFSAPIs.publish(hash, self.authHelper)
                }.done{ success in
                    Log.d(TAG(), "moveTo succeed")
                    resolver.fulfill(HiveVoid())
                    handleBy.didSucceed(HiveVoid())
                }.catch{ error in
                    Log.e(TAG(), "moveTo falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                }
        }
        return promise
    }

    override func copyTo(newPath: String) -> HivePromise<HiveVoid> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<HiveVoid>())
    }

    override func copyTo(newPath: String, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in

            let originPath = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<String> in
                    return IPFSAPIs.getHash(originPath, self.authHelper)
                }
                .then{ hash -> HivePromise<JSON> in
                    let uid = (self.authHelper as! IPFSAuthHelper).param.uid
                    let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_CP.rawValue
                    let dest = (newPath + "/").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    let params = ["uid": uid, "source": hash, "dest": dest]
                    return IPFSAPIs.request(url, .post, params)
                }
                .then{ json -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper)
                }
                .then{ hash -> HivePromise<HiveVoid> in
                    return IPFSAPIs.publish(hash, self.authHelper)
                }
                .done{ success in
                    Log.d(TAG(), "copyTo succeed")
                    resolver.fulfill(HiveVoid())
                    handleBy.didSucceed(HiveVoid())
                }
                .catch{ error in
                    Log.e(TAG(), "copyTo falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }

    override func deleteItem() -> HivePromise<HiveVoid> {
        return deleteItem(handleBy: HiveCallback<HiveVoid>())
    }

    override func deleteItem(handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_RM.rawValue
            let uid = (authHelper as! IPFSAuthHelper).param.uid
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let params = ["uid": uid, "path": path, "recursive": true] as [String : Any]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, params)
                }
                .then{ json -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper)
                }
                .then{ hash -> HivePromise<HiveVoid> in
                    return IPFSAPIs.publish(hash, self.authHelper)
                }
                .done{ success in
                    Log.d(TAG(), "deleteItem succeed")
                    resolver.fulfill(success)
                    handleBy.didSucceed(success)
                }
                .catch{ error in
                    Log.e(TAG(), "deleteItem falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
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
            let uid = (self.authHelper as! IPFSAuthHelper).param.uid
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let cacheUrl: String = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue + "?uid=" + uid + "&path=" + path
            let cachePath = cacheUrl.md5
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
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue
            let param = ["uid": uid, "path": path]
            self.authHelper.checkExpired().then{ void -> HivePromise<Data> in
                return IPFSAPIs.getRemoFiel(url, .post, param)
                }.done{ data in
                    let isSuccess = CacheHelper.saveCache(.hiveIPFS, cachePath, data: data)
                    var readData = Data()
                    if isSuccess {
                        readData = CacheHelper.readCache(.hiveIPFS, cachePath, self.cursor, length)
                    }
                    self.cursor += UInt64(readData.count)
                    Log.d(TAG(), "readData succeed")
                    resolver.fulfill(readData)
                    handleBy.didSucceed(readData)
                }.catch{ error in
                    Log.e(TAG(), "readData falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                }
        }
        return promise
    }

    override func readData(_ length: Int, _ position: UInt64) -> HivePromise<Data> {
       return readData(length, position, handleBy: HiveCallback<Data>())
    }

    override func readData(_ length: Int, _ position: UInt64, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let promise = HivePromise<Data> { resolver in
            let uid = (self.authHelper as! IPFSAuthHelper).param.uid
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let cacheUrl: String = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue + "?uid=" + uid + "&path=" + path
            let cachePath = cacheUrl.md5
            let file = CacheHelper.checkCacheFileIsExist(.hiveIPFS, cachePath)
            if file {
                let data = CacheHelper.readCache(.hiveIPFS, cachePath, position, length)
                cursor += UInt64(data.count)
                resolver.fulfill(data)
                handleBy.didSucceed(data)
                return
            }
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue
            let param = ["uid": uid, "path": path]
            self.authHelper.checkExpired().then{ void -> HivePromise<Data> in
                return IPFSAPIs.getRemoFiel(url, .post, param)
                }.done{ data in
                    let isSuccess = CacheHelper.saveCache(.hiveIPFS, cachePath, data: data)
                    var readData = Data()
                    if isSuccess {
                        readData = CacheHelper.readCache(.hiveIPFS, cachePath, position, length)
                        self.cursor += UInt64(readData.count)
                    }
                    Log.d(TAG(), "readData succeed")
                    resolver.fulfill(readData)
                    handleBy.didSucceed(readData)
                }.catch{ error in
                    Log.e(TAG(), "readData falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                }
        }
        return promise
    }

    override func writeData(withData: Data) -> HivePromise<Int32> {
        return writeData(withData: withData, handleBy: HiveCallback<Int32>())
    }

    override func writeData(withData: Data, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let promise = HivePromise<Int32> { resolver in
            let uid = (self.authHelper as! IPFSAuthHelper).param.uid
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let cacheUrl: String = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue + "?uid=" + uid + "&path=" + path
            let cachePath = cacheUrl.md5
            let file = CacheHelper.checkCacheFileIsExist(.hiveIPFS, cachePath)
            if file {
                let length = CacheHelper.writeCache(.hiveIPFS, cachePath, data: withData, 0, true)
                resolver.fulfill(length)
                handleBy.didSucceed(length)
                return
            }
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue
            let param = ["uid": uid, "path": path]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<Data> in
                    return IPFSAPIs.getRemoFiel(url, .post, param)
                }
                .done{ data in
                    _ = CacheHelper.saveCache(.hiveIPFS, cachePath, data: data)
                    let length = CacheHelper.writeCache(.hiveIPFS, cachePath, data: withData, 0, true)
                    Log.d(TAG(), "writeData succeed")
                    resolver.fulfill(length)
                    handleBy.didSucceed(length)
                }
                .catch{ error in
                    Log.e(TAG(), "writeData falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }

    override func writeData(withData: Data, _ position: UInt64) -> HivePromise<Int32> {
        return writeData(withData: withData, position, handleBy: HiveCallback<Int32>())
    }

    override func writeData(withData: Data, _ position: UInt64, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let promise = HivePromise<Int32> { resolver in
            let uid = (self.authHelper as! IPFSAuthHelper).param.uid
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let cacheUrl: String = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue + "?uid=" + uid + "&path=" + path
            let cachePath = cacheUrl.md5
            let file = CacheHelper.checkCacheFileIsExist(.hiveIPFS, cachePath)
            if file {
                let length = CacheHelper.writeCache(.hiveIPFS, cachePath, data: withData, position, false)
                resolver.fulfill(length)
                handleBy.didSucceed(length)
                return
            }
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue
            let param = ["uid": uid, "path": path]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<Data> in
                    return IPFSAPIs.getRemoFiel(url, .post, param)
                }
                .done{ data in
                    _ = CacheHelper.saveCache(.hiveIPFS, cachePath, data: data)
                    let length = CacheHelper.writeCache(.hiveIPFS, cachePath, data: withData, position, false)
                    Log.d(TAG(), "writeData succeed")
                    resolver.fulfill(length)
                    handleBy.didSucceed(length)
                }
                .catch{ error in
                    Log.e(TAG(), "writeData falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }

    override func commitData() -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            let uid = (self.authHelper as! IPFSAuthHelper).param.uid
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue + "?uid=" + uid + "&path=" + path
            let data = CacheHelper.uploadFile(.hiveIPFS, url.md5)
            self.authHelper.checkExpired().then{ succeed -> HivePromise<HiveVoid> in
                return IPFSAPIs.writeData(path, data, self.authHelper)
                }
                .then{ success -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper)
                }
                .then{ hash -> HivePromise<HiveVoid> in
                    return IPFSAPIs.publish(hash, self.authHelper)
                }
                .done{ success in
                    Log.d(TAG(), "writeData succeed")
                    resolver.fulfill(HiveVoid())
                }
                .catch{ error in
                    Log.e(TAG(), "writeData falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func discardData() {
        cursor = 0
        finish = false
        let uid = (self.authHelper as! IPFSAuthHelper).param.uid
        let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let cacheUrl = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue + "?uid=" + uid + "&path=" + path
        _ = CacheHelper.clearCache(.hiveIPFS, cacheUrl.md5)
    }

    override func close() {
        discardData()
    }
}
