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

@inline(__always) private func TAG() -> String { return "IPFSDirectory" }

class IPFSDirectory: HiveDirectoryHandle {

    override init(_ info: HiveDirectoryInfo, _ authHelper: AuthHelper) {
        super.init(info, authHelper)
    }

    override func parentPathName() -> String {
        return PathExtracter(pathName).dirNamePart()
    }

    override func lastUpdatedInfo() -> HivePromise<HiveDirectoryInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryInfo>) -> HivePromise<HiveDirectoryInfo> {
        let promise: HivePromise = HivePromise<HiveDirectoryInfo> { resolver in
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_STAT.rawValue)"
            let uid: String = (self.authHelper as! IPFSRpcHelper).param.entry.uid
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let params: Dictionary<String, String> = ["uid": uid, "path": path]
            self.authHelper?.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, params)
                }
                .done{ json in
                    Log.d(TAG(), "lastUpdatedInfo succeed")
                    let dic: Dictionary<String, String> = [HiveDirectoryInfo.itemId: uid,
                               HiveDirectoryInfo.name: PathExtracter(self.pathName).baseNamePart(),
                               HiveDirectoryInfo.childCount: String(json["Blocks"].intValue)]
                    let dirInfo: HiveDirectoryInfo = HiveDirectoryInfo(dic)
                    self.lastInfo = dirInfo
                    handleBy.didSucceed(dirInfo)
                    resolver.fulfill(dirInfo)
                }
                .catch{ error in
                    Log.e(TAG(), "lastUpdatedInfo falied: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func createDirectory(withName: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withName: withName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withName: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        let promise: HivePromise = HivePromise<HiveDirectoryHandle> { resolver in
            var path: String = "\(self.pathName)/\(withName)"
            if self.pathName == "/" {
                path = "\(self.pathName)\(withName)"
            }
            let epath : String = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_MKDIR.rawValue)"
            let uid: String = (authHelper as! IPFSRpcHelper).param.entry.uid
            let param = ["uid": uid,"path": epath]
            self.authHelper!.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, param)
                }
                .then{ json -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper!)
                }
                .then{ hash -> HivePromise<Void> in
                    return IPFSAPIs.publish(hash, self.authHelper!)
                }
                .done{ success in
                    Log.d(TAG(), "createDirectory succeed")
                    let dic: Dictionary<String, String> = [HiveDirectoryInfo.itemId: uid,
                               HiveDirectoryInfo.name: withName,
                               HiveDirectoryInfo.childCount: "0"]
                    let directoryInfo: HiveDirectoryInfo = HiveDirectoryInfo(dic)
                    let directoryHandle: IPFSDirectory = IPFSDirectory(directoryInfo, self.authHelper!)
                    directoryHandle.lastInfo = directoryInfo
                    directoryHandle.pathName = path
                    directoryHandle.drive = self.drive
                    handleBy.didSucceed(directoryHandle)
                    resolver.fulfill(directoryHandle)
                }
                .catch{ error in
                    Log.e(TAG(), "createDirectory falied: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func directoryHandle(atName: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atName: atName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func directoryHandle(atName: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        let promise: HivePromise = HivePromise<HiveDirectoryHandle> { resolver in
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_STAT.rawValue)"
            let uid: String = (self.authHelper as! IPFSRpcHelper).param.entry.uid
            var path: String = "\(self.pathName)/\(atName)"
            if self.pathName == "/" {
                path = "\(self.pathName)\(atName)"
            }
            let epath: String = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let param: Dictionary<String, String> = ["uid": uid, "path": epath]
            self.authHelper?.checkExpired()
                .then{ json -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, param)
                }
                .done{ json in
                    Log.d(TAG(), "directoryHandle succeed")
                    let dic: Dictionary<String, String> = [HiveDirectoryInfo.itemId: uid,
                               HiveDirectoryInfo.name: atName,
                               HiveDirectoryInfo.childCount: String(json["Blocks"].intValue)]
                    let directoryInfo: HiveDirectoryInfo = HiveDirectoryInfo(dic)
                    let directoryHandle: IPFSDirectory = IPFSDirectory(directoryInfo, self.authHelper!)
                    directoryHandle.lastInfo = directoryInfo
                    directoryHandle.pathName = path
                    directoryHandle.drive = self.drive
                    handleBy.didSucceed(directoryHandle)
                    resolver.fulfill(directoryHandle)
                }
                .catch{ error in
                    Log.e(TAG(), "directoryHandle falied: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func createFile(withName: String) -> HivePromise<HiveFileHandle> {
        return createFile(withName: withName, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func createFile(withName: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        let promise: HivePromise = HivePromise<HiveFileHandle> { resolver in
            var path: String = "\(self.pathName)/\(withName)"
            if self.pathName == "/" {
                path = "\(self.pathName)\(withName)"
            }
            let epath: String = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            self.authHelper!.checkExpired()
                .then{ succeed -> HivePromise<JSON> in
                    return IPFSAPIs.creatFile(epath, self.authHelper!)
                }
                .then{ json -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper!)
                }
                .then{ hash -> HivePromise<Void> in
                    return IPFSAPIs.publish(hash, self.authHelper!)
                }
                .done{ success in
                    Log.d(TAG(), "createFile succeed")
                    let uid: String = (self.authHelper as! IPFSRpcHelper).param.entry.uid
                    let dic: Dictionary<String, String> = [HiveFileInfo.itemId: uid,
                               HiveFileInfo.name: PathExtracter(withName).baseNamePart(),
                               HiveFileInfo.size: "0"]
                    let fileInfo: HiveFileInfo = HiveFileInfo(dic)
                    let fileHandle: IPFSFile = IPFSFile(fileInfo, self.authHelper!)
                    fileHandle.pathName = path
                    fileHandle.lastInfo = fileInfo
                    fileHandle.drive = self.drive
                    handleBy.didSucceed(fileHandle)
                    resolver.fulfill(fileHandle)
                }.catch{ error in
                    Log.e(TAG(), "createFile falied: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func fileHandle(atName: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atName: atName, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func fileHandle(atName: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        let promise: HivePromise = HivePromise<HiveFileHandle> { resolver in
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_STAT.rawValue)"
            let uid: String = (self.authHelper as! IPFSRpcHelper).param.entry.uid
            var path: String = "\(self.pathName)/\(atName)"
            if self.pathName == "/" {
                path = "\(self.pathName)\(atName)"
            }
            let epath: String = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let param: Dictionary<String, String> = ["uid": uid, "path": epath]
            self.authHelper?.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, param)
                }
                .done{ json in
                    Log.d(TAG(), "fileHandle succeed")
                    let dic: Dictionary<String, String> = [HiveFileInfo.itemId: uid,
                               HiveFileInfo.name: PathExtracter(atName).baseNamePart(),
                               HiveFileInfo.size: String(json["Size"].uInt64Value)]
                    let fileInfo: HiveFileInfo = HiveFileInfo(dic)
                    let fileHandle: IPFSFile = IPFSFile(fileInfo, self.authHelper!)
                    fileHandle.lastInfo = fileInfo
                    fileHandle.pathName = path
                    fileHandle.drive = self.drive
                    handleBy.didSucceed(fileHandle)
                    resolver.fulfill(fileHandle)
                }
                .catch{ error in
                    Log.e(TAG(), "fileHandle falied: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func getChildren() -> HivePromise<HiveChildren> {
        return getChildren(handleBy: HiveCallback<HiveChildren>())
    }

    override func getChildren(handleBy: HiveCallback<HiveChildren>) -> HivePromise<HiveChildren> {
        let promise: HivePromise = HivePromise<HiveChildren> { resolver in
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_LS.rawValue)"
            let uid: String = (self.authHelper as! IPFSRpcHelper).param.entry.uid
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let param: Dictionary<String, String> = ["uid": uid, "path": path]
            self.authHelper?.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, param)
                }
                .done{ void in
                    Log.d(TAG(), "getChildren succeed")
                    let children = HiveChildren()
                    handleBy.didSucceed(children)
                    resolver.fulfill(children)
                }
                .catch{ error in
                    Log.e(TAG(), "getChildren falied: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func moveTo(newPath: String) -> HivePromise<Void> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Void>())
    }

    override func moveTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let promise: HivePromise = HivePromise<Void> { resolver in
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_MV.rawValue)"
            let uid: String = (authHelper as! IPFSRpcHelper).param.entry.uid
            let originPath: String = self.pathName
            let dest: String = newPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let params: Dictionary<String, String> = ["uid": uid,
                          "source": originPath,
                          "dest": dest]
            self.authHelper?.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, params)
                }
                .then{ json -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper!)
                }
                .then{ hash -> HivePromise<Void> in
                    return IPFSAPIs.publish(hash, self.authHelper!)
                }
                .done{ void in
                    Log.d(TAG(), "moveTo succeed")
                    handleBy.didSucceed(Void())
                    resolver.fulfill(Void())
                }
                .catch{ error in
                    Log.e(TAG(), "moveTo falied: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func copyTo(newPath: String) -> HivePromise<Void> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Void>())
    }

    override func copyTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let promise: HivePromise = HivePromise<Void> { resolver in
            let originPath: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let newPath: String = newPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            self.authHelper?.checkExpired()
                .then{ void -> HivePromise<String> in
                    return IPFSAPIs.getHash(originPath, self.authHelper!)
                }
                .then{ hash -> HivePromise<JSON> in
                    let url: String = "\((self.authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_CP.rawValue)"
                    let uid: String = (self.authHelper as! IPFSRpcHelper).param.entry.uid
                    let params: Dictionary<String, String> = ["uid": uid, "source": hash, "dest": newPath]
                    return IPFSAPIs.request(url, .post, params)
                }
                .then{ json -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper!)
                }
                .then{ hash -> HivePromise<Void> in
                    return IPFSAPIs.publish(hash, self.authHelper!)
                }
                .done{ success in
                    Log.d(TAG(), "copyTo succeed")
                    handleBy.didSucceed(Void())
                    resolver.fulfill(Void())
                }.catch{ error in
                    Log.e(TAG(), "copyTo falied: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func deleteItem() -> HivePromise<Void> {
        return deleteItem(handleBy: HiveCallback<Void>())
    }

    override func deleteItem(handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let promise: HivePromise = HivePromise<Void> { resolver in
            let url: String = "\((authHelper as! IPFSRpcHelper).param.entry.rpcAddrs[validIp])\(HIVE_SUB_Url.IPFS_FILES_RM.rawValue)"
            let uid: String = (authHelper as! IPFSRpcHelper).param.entry.uid
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let params: Dictionary<String, Any> = ["uid": uid, "path": path, "recursive": true]
            self.authHelper?.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, params)
                }
                .then{ hash -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper!)
                }
                .then{ hash -> HivePromise<Void> in
                    return IPFSAPIs.publish(hash, self.authHelper!)
                }
                .done{ success in
                    Log.d(TAG(), "deleteItem succeed")
                    handleBy.didSucceed(success)
                    resolver.fulfill(success)
                }
                .catch{ error in
                    Log.e(TAG(), "deleteItem falied: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

}
