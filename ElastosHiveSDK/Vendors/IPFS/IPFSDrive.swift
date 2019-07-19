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
import PromiseKit
import Alamofire

@inline(__always) private func TAG() -> String { return "IPFSDrive" }

@objc(IPFSDrive)
internal class IPFSDrive: HiveDriveHandle {
    private var authHelper: AuthHelper
    internal static var hiveDriveInstance: HiveDriveHandle?

    init(_ info: HiveDriveInfo, _ authHelper: AuthHelper) {
        self.authHelper = authHelper
        super.init(.hiveIPFS, info)
        IPFSDrive.hiveDriveInstance = self
    }

    static func sharedInstance() -> IPFSDrive {
        return hiveDriveInstance as! IPFSDrive
    }

    override func lastUpdatedInfo() -> HivePromise<HiveDriveInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>) -> HivePromise<HiveDriveInfo> {
        let promise = HivePromise<HiveDriveInfo> { resolver in
            let url = (authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
            let uid = (self.authHelper as! IPFSRpcHelper).param.entry.uid
            let path = "/".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let params = ["uid": uid, "path": path]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, params)
                }
                .done{ sueecee in
                    Log.d(TAG(), "lastUpdatedInfo succeed")
                    let dic: Dictionary<String, String> = [HiveDriveInfo.driveId: uid]
                    let driveInfo = HiveDriveInfo(dic)
                    self.lastInfo = driveInfo
                    handleBy.didSucceed(driveInfo)
                    resolver.fulfill(driveInfo)
                }
                .catch{ error in
                    Log.e(TAG(), "lastUpdatedInfo falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }

    override func rootDirectoryHandle() -> HivePromise<HiveDirectoryHandle> {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                let url = (authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp] + HIVE_SUB_Url.IPFS_FILES_LS.rawValue
                let uid = (self.authHelper as! IPFSRpcHelper).param.entry.uid
                let path = "/".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let params = ["uid": uid, "path": path]

                self.authHelper.checkExpired()
                    .then{ void -> HivePromise<JSON> in
                        return IPFSAPIs.request(url, .post, params)
                    }
                    .done{ json in
                        Log.d(TAG(), "rootDirectoryHandle succeed")
                        let dic = [HiveDirectoryInfo.itemId: uid,
                                   HiveDirectoryInfo.name: "/",
                                   HiveDirectoryInfo.childCount: String(json["Entries"].count)]
                        let directoryInfo = HiveDirectoryInfo(dic)
                        let directoryHandle = IPFSDirectory(directoryInfo, self.authHelper)
                        directoryHandle.lastInfo = directoryInfo
                        directoryHandle.pathName = "/"
                        directoryHandle.drive = self
                        resolver.fulfill(directoryHandle)
                        handleBy.didSucceed(directoryHandle)
                    }
                    .catch{ error in
                        Log.e(TAG(), "rootDirectoryHandle falied: " + HiveError.des(error as! HiveError))
                        handleBy.runError(error as! HiveError)
                        resolver.reject(error)
                }
            }
            return promise
    }

    override func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath,
                               handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                let url = (authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp] + HIVE_SUB_Url.IPFS_FILES_MKDIR.rawValue
                let uid = (authHelper as! IPFSRpcHelper).param.entry.uid
                let path = withPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let param = ["uid": uid,"path": path]

                self.authHelper.checkExpired().then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, param)
                    }.then{ json -> HivePromise<String> in
                        return IPFSAPIs.getHash("/", self.authHelper)
                    }.then{  hash -> HivePromise<Void>  in
                        return IPFSAPIs.publish(hash, self.authHelper)
                    }.done{ success in
                        Log.d(TAG(), "createDirectory succeed")
                        let uid = (self.authHelper as! IPFSRpcHelper).param.entry.uid
                        let dic = [HiveDirectoryInfo.itemId: uid,
                                   HiveDirectoryInfo.name: PathExtracter(withPath).baseNamePart(),
                                   HiveDirectoryInfo.childCount: "0"]
                        let directoryInfo = HiveDirectoryInfo(dic)
                        let directoryHandle = IPFSDirectory(directoryInfo, self.authHelper)
                        directoryHandle.lastInfo = directoryInfo
                        directoryHandle.pathName = withPath
                        directoryHandle.drive = self
                        resolver.fulfill(directoryHandle)
                        handleBy.didSucceed(directoryHandle)
                    }.catch{ error in
                        Log.e(TAG(), "createDirectory falied: " + HiveError.des(error as! HiveError))
                        resolver.reject(error)
                        handleBy.runError(error as! HiveError)
                }
            }
            return promise
    }

    override func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atPath: atPath,
                               handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {

            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                let url = (authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
                let uid = (self.authHelper as! IPFSRpcHelper).param.entry.uid
                let path = atPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let param = ["uid": uid, "path": path]

                self.authHelper.checkExpired()
                    .then{ void -> HivePromise<JSON> in
                        return IPFSAPIs.request(url, .post, param)
                    }
                    .done{ json in
                        Log.d(TAG(), "directoryHandle succeed")
                        let dic = [HiveDirectoryInfo.itemId: uid,
                                   HiveDirectoryInfo.name: PathExtracter(atPath).baseNamePart(),
                                   HiveDirectoryInfo.childCount:String(json["Blocks"].stringValue)]
                        let directoryInfo = HiveDirectoryInfo(dic)
                        let directoryHandle = IPFSDirectory(directoryInfo, self.authHelper)
                        directoryHandle.lastInfo = directoryInfo
                        directoryHandle.pathName = atPath
                        directoryHandle.drive = self
                        resolver.fulfill(directoryHandle)
                        handleBy.didSucceed(directoryHandle)
                    }
                    .catch{ error in
                        Log.e(TAG(), "directoryHandle falied: " + HiveError.des(error as! HiveError))
                        resolver.reject(error)
                        handleBy.runError(error as! HiveError)
                }
            }
            return promise
    }

    override func createFile(withPath: String) -> HivePromise<HiveFileHandle> {
        return createFile(withPath: withPath,
                          handleBy: HiveCallback<HiveFileHandle>())
    }

    override func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle> {
            let path = withPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let promise = HivePromise<HiveFileHandle> { resolver in
                self.authHelper.checkExpired()
                    .then{ void -> HivePromise<JSON> in
                        return IPFSAPIs.creatFile(path, self.authHelper)
                    }
                    .then{ json -> HivePromise<String> in
                        return IPFSAPIs.getHash("/", self.authHelper)
                    }
                    .then{ hash -> HivePromise<Void> in
                        return IPFSAPIs.publish(hash, self.authHelper)
                    }
                    .done{ success in
                        Log.d(TAG(), "createFile succeed")
                        let uid = (self.authHelper as! IPFSRpcHelper).param.entry.uid
                        let dic = [HiveFileInfo.itemId: uid,
                                   HiveFileInfo.name: PathExtracter(withPath).baseNamePart(),
                                   HiveFileInfo.size: "0"]
                        let fileInfo = HiveFileInfo(dic)
                        let fileHandle = IPFSFile(fileInfo, self.authHelper)
                        fileHandle.pathName = withPath
                        fileHandle.lastInfo = fileInfo
                        fileHandle.drive = self
                        handleBy.didSucceed(fileHandle)
                        resolver.fulfill(fileHandle)
                    }
                    .catch{ error in
                        Log.e(TAG(), "directoryHandle falied: " + HiveError.des(error as! HiveError))
                        handleBy.runError(error as! HiveError)
                        resolver.reject(error)
                }
            }
            return promise
    }

    override func fileHandle(atPath: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle> {
            let promise = HivePromise<HiveFileHandle> { resolver in
                let url = (authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
                let uid = (self.authHelper as! IPFSRpcHelper).param.entry.uid
                let path = atPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let param = ["uid": uid, "path": path]
                self.authHelper.checkExpired()
                    .then{ void -> HivePromise<JSON> in
                        return IPFSAPIs.request(url, .post, param)
                    }
                    .done{ json in
                        Log.d(TAG(), "fileHandle succeed")
                        let dic = [HiveFileInfo.itemId: uid,
                                   HiveFileInfo.name: PathExtracter(atPath).baseNamePart(),
                                   HiveFileInfo.size: String(json["Size"].uInt64Value)]
                        let fileInfo = HiveFileInfo(dic)
                        let fileHandle = IPFSFile(fileInfo, self.authHelper)
                        fileHandle.lastInfo = fileInfo
                        fileHandle.pathName = atPath
                        fileHandle.drive = self
                        let pathName = ("/" + PathExtracter(atPath).baseNamePart()).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                        let url = (self.authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp] + HIVE_SUB_Url.IPFS_FILES_READ.rawValue + "?uid=" + uid + "&path=" + pathName
                        _ = CacheHelper.clearCache(.hiveIPFS, url.md5)
                        resolver.fulfill(fileHandle)
                        handleBy.didSucceed(fileHandle)
                    }
                    .catch{ error in
                        Log.e(TAG(), "fileHandle falied: " + HiveError.des(error as! HiveError))
                        resolver.reject(error)
                        handleBy.runError(error as! HiveError)
                }
            }
            return promise
    }

    override func getItemInfo(_ path: String) -> HivePromise<HiveItemInfo> {
        return getItemInfo(path, handleBy: HiveCallback<HiveItemInfo>())
    }

    override func getItemInfo(_ path: String, handleBy: HiveCallback<HiveItemInfo>) -> HivePromise<HiveItemInfo> {
        let promise = HivePromise<HiveItemInfo> { resolver in
            let url = (authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
            let uid = (self.authHelper as! IPFSRpcHelper).param.entry.uid
            let path = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let param = ["uid": uid, "path": path]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, param)
                }
                .done{ jsonData in
                    Log.d(TAG(), "getItemInfo succeed")
                    let dic = [HiveItemInfo.itemId: uid,
                               HiveItemInfo.name: PathExtracter(path).baseNamePart(),
                               HiveItemInfo.size: String(jsonData["Size"].uInt64Value),
                               HiveItemInfo.type: jsonData["Type"].stringValue]
                    let itemInfo = HiveItemInfo(dic)
                    resolver.fulfill(itemInfo)
                    handleBy.didSucceed(itemInfo)
                }
                .catch{ error in
                    Log.e(TAG(), "getItemInfo falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }
}
