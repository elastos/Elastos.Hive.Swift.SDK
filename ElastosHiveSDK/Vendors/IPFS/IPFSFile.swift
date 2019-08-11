/*
 * Copyright (c) 2019 Elastos Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation

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
        return lastUpdatedInfo(handleBy: nil)
    }

    override func lastUpdatedInfo(handleBy: ((HiveCallback<HiveFileInfo>) -> Void)?) -> HivePromise<HiveFileInfo> {
        let promise: HivePromise = HivePromise<HiveFileInfo> { resolver in
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_STAT.rawValue)"
            let uid: String = (self.authHelper as! IPFSRpcHelper).param.entry.uid
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let params: Dictionary<String, String> = ["uid": uid, "path": path]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, params)
                }
                .done{ jsonData in
                    Log.d(TAG(), "lastUpdatedInfo succeed")
                    let dic: Dictionary<String, String> = [HiveFileInfo.itemId: uid,
                               HiveFileInfo.name: PathExtracter(self.pathName).baseNamePart(),
                               HiveFileInfo.size: String(jsonData["Size"].uInt64Value)]
                    let fileInfo: HiveFileInfo = HiveFileInfo(dic)
                    self.lastInfo = fileInfo
                    if handleBy != nil {
                        handleBy!(.success(fileInfo))
                    }
                    resolver.fulfill(fileInfo)
                }
                .catch{ error in
                    Log.e(TAG(), "lastUpdatedInfo falied: \(HiveError.des(error as! HiveError))")
                    if handleBy != nil {
                        handleBy!(.failure(error as! HiveError))
                    }
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func moveTo(newPath: String) -> HivePromise<Void> {
        return moveTo(newPath: newPath, handleBy: nil)
    }

    override func moveTo(newPath: String, handleBy: ((HiveCallback<Void>) -> Void)?) -> HivePromise<Void> {
        let promise: HivePromise = HivePromise<Void> { resolver in
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_MV.rawValue)"
            let uid: String = (authHelper as! IPFSRpcHelper).param.entry.uid
            let originPath: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let dest: String = newPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let params: Dictionary<String, String> = ["uid": uid, "source": originPath, "dest": dest]

            self.authHelper.checkExpired().then{ Void -> HivePromise<JSON> in
                return IPFSAPIs.request(url, .post, params)
                }.then{ json -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper)
                }.then{ hash -> HivePromise<Void> in
                    return IPFSAPIs.publish(hash, self.authHelper)
                }.done{ success in
                    Log.d(TAG(), "moveTo succeed")
                    if handleBy != nil {
                        handleBy!(.success(Void()))
                    }
                    resolver.fulfill(Void())
                }.catch{ error in
                    Log.e(TAG(), "moveTo falied: \(HiveError.des(error as! HiveError))")
                    if handleBy != nil {
                        handleBy!(.failure(error as! HiveError))
                    }
                    resolver.reject(error)
                }
        }
        return promise
    }

    override func copyTo(newPath: String) -> HivePromise<Void> {
        return copyTo(newPath: newPath, handleBy: nil)
    }

    override func copyTo(newPath: String, handleBy: ((HiveCallback<Void>) -> Void)?) -> HivePromise<Void> {
        let promise: HivePromise = HivePromise<Void> { resolver in

            let originPath: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<String> in
                    return IPFSAPIs.getHash(originPath, self.authHelper)
                }
                .then{ hash -> HivePromise<JSON> in
                    let uid: String = (self.authHelper as! IPFSRpcHelper).param.entry.uid
                    let url: String = "\((self.authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_CP.rawValue)"
                    let dest: String = "\(newPath)/".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    let params: Dictionary<String, String> = ["uid": uid, "source": hash, "dest": dest]
                    return IPFSAPIs.request(url, .post, params)
                }
                .then{ json -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper)
                }
                .then{ hash -> HivePromise<Void> in
                    return IPFSAPIs.publish(hash, self.authHelper)
                }
                .done{ success in
                    Log.d(TAG(), "copyTo succeed")
                    if handleBy != nil {
                        handleBy!(.success(Void()))
                    }
                    resolver.fulfill(Void())
                }
                .catch{ error in
                    Log.e(TAG(), "copyTo falied: \(HiveError.des(error as! HiveError))")
                    if handleBy != nil {
                        handleBy!(.failure(error as! HiveError))
                    }
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func deleteItem() -> HivePromise<Void> {
        return deleteItem(handleBy: nil)
    }

    override func deleteItem(handleBy: ((HiveCallback<Void>) -> Void)?) -> HivePromise<Void> {
        let promise: HivePromise = HivePromise<Void> { resolver in
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_RM.rawValue)"
            let uid: String = (authHelper as! IPFSRpcHelper).param.entry.uid
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let params: Dictionary<String, Any> = ["uid": uid, "path": path, "recursive": true]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, params)
                }
                .then{ json -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper)
                }
                .then{ hash -> HivePromise<Void> in
                    return IPFSAPIs.publish(hash, self.authHelper)
                }
                .done{ success in
                    Log.d(TAG(), "deleteItem succeed")
                    if handleBy != nil {
                        handleBy!(.success(success))
                    }
                    resolver.fulfill(success)
                }
                .catch{ error in
                    Log.e(TAG(), "deleteItem falied: \(HiveError.des(error as! HiveError))")
                    if handleBy != nil {
                        handleBy!(.failure(error as! HiveError))
                    }
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func readData(_ length: Int) -> HivePromise<Data> {
        return readData(length, handleBy: nil)
    }

    override func readData(_ length: Int, handleBy: ((HiveCallback<Data>) -> Void)?) -> HivePromise<Data> {
        let promise: HivePromise = HivePromise<Data> { resolver in
            if finish {
                Log.e(TAG(), "The file has been read finished")
                if handleBy != nil {
                    handleBy!(.success(Data()))
                }
                resolver.fulfill(Data())
                return
            }
            let uid: String = (self.authHelper as! IPFSRpcHelper).param.entry.uid
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\( HIVE_SUB_Url.IPFS_FILES_READ.rawValue)?uid=\(uid)&path=\(path)"
            let cachePath: String = url.md5
            let file: Bool = CacheHelper.checkCacheFileIsExist((drive as! IPFSDrive).param!.keyStorePath, cachePath)
            if file {
                let data: Data = CacheHelper.readCache((drive as! IPFSDrive).param!.keyStorePath, cachePath, cursor, length)
                cursor = cursor + UInt64(data.count)
                resolver.fulfill(data)
                if handleBy != nil {
                    handleBy!(.success(data))
                }
                if data.count == 0 {
                    cursor = 0
                    finish = true
                }
                return
            }
            self.authHelper.checkExpired().then{ void -> HivePromise<Data> in
                return IPFSAPIs.getRemoFiel(url, .post, nil)
                }.done{ data in
                    let isSuccess = CacheHelper.saveCache((self.drive as! IPFSDrive).param!.keyStorePath, cachePath, data: data)
                    var readData = Data()
                    if isSuccess {
                        readData = CacheHelper.readCache((self.drive as! IPFSDrive).param!.keyStorePath, cachePath, self.cursor, length)
                    }
                    self.cursor = self.cursor + UInt64(readData.count)
                    Log.d(TAG(), "readData succeed")
                    if handleBy != nil {
                        handleBy!(.success(readData))
                    }
                    resolver.fulfill(readData)
                }.catch{ error in
                    Log.e(TAG(), "readData falied: \(HiveError.des(error as! HiveError))")
                    if handleBy != nil {
                        handleBy!(.failure(error as! HiveError))
                    }
                    resolver.reject(error)
                }
        }
        return promise
    }

    override func readData(_ length: Int, _ position: UInt64) -> HivePromise<Data> {
       return readData(length, position, handleBy: nil)
    }

    override func readData(_ length: Int, _ position: UInt64, handleBy: ((HiveCallback<Data>) -> Void)?) -> HivePromise<Data> {
        let promise: HivePromise = HivePromise<Data> { resolver in
            let uid: String = (self.authHelper as! IPFSRpcHelper).param.entry.uid
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_READ.rawValue)?uid=\(uid)&path=\(path)"
            let cachePath: String = url.md5
            let file: Bool = CacheHelper.checkCacheFileIsExist((drive as! IPFSDrive).param!.keyStorePath, cachePath)
            if file {
                let data: Data = CacheHelper.readCache((drive as! IPFSDrive).param!.keyStorePath, cachePath, position, length)
                cursor += UInt64(data.count)
                if handleBy != nil {
                    handleBy!(.success(data))
                }
                resolver.fulfill(data)
                return
            }
            self.authHelper.checkExpired().then{ void -> HivePromise<Data> in
                return IPFSAPIs.getRemoFiel(url, .post, nil)
                }.done{ data in
                    let isSuccess: Bool = CacheHelper.saveCache((self.drive as! IPFSDrive).param!.keyStorePath, cachePath, data: data)
                    var readData = Data()
                    if isSuccess {
                        readData = CacheHelper.readCache((self.drive as! IPFSDrive).param!.keyStorePath, cachePath, position, length)
                        self.cursor += UInt64(readData.count)
                    }
                    Log.d(TAG(), "readData succeed")
                    if handleBy != nil {
                        handleBy!(.success(readData))
                    }
                    resolver.fulfill(readData)
                }.catch{ error in
                    Log.e(TAG(), "readData falied: \(HiveError.des(error as! HiveError))")
                    if handleBy != nil {
                        handleBy!(.failure(error as! HiveError))
                    }
                    resolver.reject(error)
                }
        }
        return promise
    }

    override func writeData(withData: Data) -> HivePromise<Int32> {
        return writeData(withData: withData, handleBy: nil)
    }

    override func writeData(withData: Data, handleBy: ((HiveCallback<Int32>) -> Void)?) -> HivePromise<Int32> {
        let promise: HivePromise = HivePromise<Int32> { resolver in
            let uid: String = (self.authHelper as! IPFSRpcHelper).param.entry.uid
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let cacheUrl: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_READ.rawValue)?uid=\(uid)&path=\(path)"
            let cachePath: String = cacheUrl.md5
            let file: Bool = CacheHelper.checkCacheFileIsExist((drive as! IPFSDrive).param!.keyStorePath, cachePath)
            if file {
                let length = CacheHelper.writeCache((drive as! IPFSDrive).param!.keyStorePath, cachePath, data: withData, 0, true)
                if handleBy != nil {
                    handleBy!(.success(length))
                }
                resolver.fulfill(length)
                return
            }
            let url: String = (authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue
            let param: Dictionary<String, String> = ["uid": uid, "path": path]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<Data> in
                    return IPFSAPIs.getRemoFiel(url, .post, param)
                }
                .done{ data in
                    _ = CacheHelper.saveCache((self.drive as! IPFSDrive).param!.keyStorePath, cachePath, data: data)
                    let length = CacheHelper.writeCache((self.drive as! IPFSDrive).param!.keyStorePath, cachePath, data: withData, 0, true)
                    Log.d(TAG(), "writeData succeed")
                    if handleBy != nil {
                        handleBy!(.success(length))
                    }
                    resolver.fulfill(length)
                }
                .catch{ error in
                    Log.e(TAG(), "writeData falied: \(HiveError.des(error as! HiveError))")
                    if handleBy != nil {
                        handleBy!(.failure(error as! HiveError))
                    }
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func writeData(withData: Data, _ position: UInt64) -> HivePromise<Int32> {
        return writeData(withData: withData, position, handleBy: nil)
    }

    override func writeData(withData: Data, _ position: UInt64, handleBy: ((HiveCallback<Int32>) -> Void)?) -> HivePromise<Int32> {
        let promise: HivePromise = HivePromise<Int32> { resolver in
            let uid: String = (self.authHelper as! IPFSRpcHelper).param.entry.uid
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let cacheUrl: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_READ.rawValue)?uid=\(uid)&path=\(path)"
            let cachePath: String = cacheUrl.md5
            let file: Bool = CacheHelper.checkCacheFileIsExist((drive as! IPFSDrive).param!.keyStorePath, cachePath)
            if file {
                let length = CacheHelper.writeCache((drive as! IPFSDrive).param!.keyStorePath, cachePath, data: withData, position, false)
                if handleBy != nil {
                    handleBy!(.success(length))
                }
                resolver.fulfill(length)
                return
            }
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_READ.rawValue)"
            let param: Dictionary<String, String> = ["uid": uid, "path": path]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<Data> in
                    return IPFSAPIs.getRemoFiel(url, .post, param)
                }
                .done{ data in
                    _ = CacheHelper.saveCache((self.drive as! IPFSDrive).param!.keyStorePath, cachePath, data: data)
                    let length = CacheHelper.writeCache((self.drive as! IPFSDrive).param!.keyStorePath, cachePath, data: withData, position, false)
                    Log.d(TAG(), "writeData succeed")
                    if handleBy != nil {
                        handleBy!(.success(length))
                    }
                    resolver.fulfill(length)
                }
                .catch{ error in
                    Log.e(TAG(), "writeData falied: \(HiveError.des(error as! HiveError))")
                    if handleBy != nil {
                        handleBy!(.failure(error as! HiveError))
                    }
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func commitData() -> HivePromise<Void> {
        return commitData(handleBy: nil)
    }

    override func commitData(handleBy: ((HiveCallback<Void>) -> Void)?) -> HivePromise<Void> {
        let promise: HivePromise = HivePromise<Void> { resolver in
            let uid: String = (self.authHelper as! IPFSRpcHelper).param.entry.uid
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_READ.rawValue)?uid=\(uid)&path=\(path)"
            let data: Data = CacheHelper.uploadFile((drive as! IPFSDrive).param!.keyStorePath, url.md5)
            self.authHelper.checkExpired().then{ succeed -> HivePromise<Void> in
                return IPFSAPIs.writeData(path, data, self.authHelper)
                }
                .then{ success -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper)
                }
                .then{ hash -> HivePromise<Void> in
                    return IPFSAPIs.publish(hash, self.authHelper)
                }
                .done{ success in
                    Log.d(TAG(), "writeData succeed")
                    if handleBy != nil {
                        handleBy!(.success(Void()))
                    }
                    resolver.fulfill(Void())
                }
                .catch{ error in
                    Log.e(TAG(), "writeData falied: \(HiveError.des(error as! HiveError))")
                    if handleBy != nil {
                        handleBy!(.failure(error as! HiveError))
                    }
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func discardData() {
        cursor = 0
        finish = false
        let uid: String = (self.authHelper as! IPFSRpcHelper).param.entry.uid
        let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let cacheUrl: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_READ.rawValue)?uid=\(uid)&path=\(path)"
        _ = CacheHelper.clearCache((drive as! IPFSDrive).param!.keyStorePath, cacheUrl.md5)
    }

}
