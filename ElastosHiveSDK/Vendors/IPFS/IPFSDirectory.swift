import Foundation
import Alamofire
import PromiseKit

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
        let promise = HivePromise<HiveDirectoryInfo> { resolver in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
            let uid = (self.authHelper as! IPFSAuthHelper).param.uid
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let params = ["uid": uid, "path": path]
            self.authHelper?.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, params)
                }
                .done{ json in
                    Log.d(TAG(), "lastUpdatedInfo succeed")
                    let dic = [HiveDirectoryInfo.itemId: uid]
                    let dirInfo = HiveDirectoryInfo(dic)
                    self.lastInfo = dirInfo
                    handleBy.didSucceed(dirInfo)
                    resolver.fulfill(dirInfo)
                }
                .catch{ error in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "lastUpdatedInfo falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
            }
        }
        return promise
    }

    override func createDirectory(withName: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withName: withName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withName: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        let promise = HivePromise<HiveDirectoryHandle> { resolver in
            var path = self.pathName + "/" + withName
            if self.pathName == "/" {
                path = self.pathName + withName
            }
            path = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_MKDIR.rawValue
            let uid = (authHelper as! IPFSAuthHelper).param.uid
            let param = ["uid": uid,"path": path]
            self.authHelper!.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, param)
                }
                .then{ json -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper!)
                }
                .then{ hash -> HivePromise<HiveVoid> in
                    return IPFSAPIs.publish(hash, self.authHelper!)
                }
                .done{ success in
                    Log.d(TAG(), "createDirectory succeed")
                    let dic = [HiveDirectoryInfo.itemId: uid]
                    let directoryInfo = HiveDirectoryInfo(dic)
                    let directoryHandle = IPFSDirectory(directoryInfo, self.authHelper!)
                    directoryHandle.lastInfo = directoryInfo
                    directoryHandle.pathName = path
                    directoryHandle.drive = self.drive
                    resolver.fulfill(directoryHandle)
                    handleBy.didSucceed(directoryHandle)
                }
                .catch{ error in
                    let hiveError = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "createDirectory falied: %s", error.localizedDescription)
                    resolver.reject(hiveError)
                    handleBy.runError(hiveError)
            }
        }
        return promise
    }

    override func directoryHandle(atName: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atName: atName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func directoryHandle(atName: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        let promise = HivePromise<HiveDirectoryHandle> { resolver in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
            let uid = (self.authHelper as! IPFSAuthHelper).param.uid
            var path = self.pathName + "/" + atName
            if self.pathName == "/" {
                path = self.pathName + atName
            }
            path = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let param = ["uid": uid, "path": path]
            self.authHelper?.checkExpired()
                .then{ json -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, param)
                }
                .done{ json in
                    Log.d(TAG(), "directoryHandle succeed")
                    let dic = [HiveDirectoryInfo.itemId: uid]
                    let directoryInfo = HiveDirectoryInfo(dic)
                    let directoryHandle = IPFSDirectory(directoryInfo, self.authHelper!)
                    directoryHandle.lastInfo = directoryInfo
                    directoryHandle.pathName = path
                    directoryHandle.drive = self.drive
                    resolver.fulfill(directoryHandle)
                    handleBy.didSucceed(directoryHandle)
                }
                .catch{ error in
                    Log.e(TAG(), "directoryHandle falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }

    override func createFile(withName: String) -> HivePromise<HiveFileHandle> {
        return createFile(withName: withName, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func createFile(withName: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        let promise = HivePromise<HiveFileHandle> { resolver in
            var path = self.pathName + "/" + withName
            if self.pathName == "/" {
                path = self.pathName + withName
            }
            path = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            self.authHelper!.checkExpired()
                .then{ succeed -> HivePromise<JSON> in
                    return IPFSAPIs.creatFile(path, self.authHelper!)
                }
                .then{ json -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper!)
                }
                .then{ hash -> HivePromise<HiveVoid> in
                    return IPFSAPIs.publish(hash, self.authHelper!)
                }
                .done{ success in
                    Log.d(TAG(), "createFile succeed")
                    let uid = (self.authHelper as! IPFSAuthHelper).param.uid
                    let dic = [HiveFileInfo.itemId: uid]
                    let fileInfo = HiveFileInfo(dic)
                    let fileHandle = IPFSFile(fileInfo, self.authHelper!)
                    fileHandle.pathName = path
                    fileHandle.lastInfo = fileInfo
                    fileHandle.drive = self.drive
                    handleBy.didSucceed(fileHandle)
                    resolver.fulfill(fileHandle)
                }.catch{ error in
                    let hiveError = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "createFile falied: %s", error.localizedDescription)
                    handleBy.runError(hiveError)
                    resolver.reject(hiveError)
            }
        }
        return promise
    }

    override func fileHandle(atName: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atName: atName, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func fileHandle(atName: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        let promise = HivePromise<HiveFileHandle> { resolver in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
            let uid = (self.authHelper as! IPFSAuthHelper).param.uid
            var path = self.pathName + "/" + atName
            if self.pathName == "/" {
                path = self.pathName + atName
            }
            path = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let param = ["uid": uid, "path": path]
            self.authHelper?.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, param)
                }
                .done{ json in
                    Log.d(TAG(), "fileHandle succeed")
                    let dic = [HiveDirectoryInfo.itemId: uid]
                    let fileInfo = HiveFileInfo(dic)
                    let fileHandle = IPFSFile(fileInfo, self.authHelper!)
                    fileHandle.lastInfo = fileInfo
                    fileHandle.pathName = path
                    fileHandle.drive = self.drive
                    resolver.fulfill(fileHandle)
                    handleBy.didSucceed(fileHandle)
                }
                .catch{ error in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "fileHandle falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
            }
        }
        return promise
    }

    override func getChildren() -> HivePromise<HiveChildren> {
        return getChildren(handleBy: HiveCallback<HiveChildren>())
    }

    override func getChildren(handleBy: HiveCallback<HiveChildren>) -> HivePromise<HiveChildren> {
        let promise = HivePromise<HiveChildren> { resolver in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_LS.rawValue
            let uid = (self.authHelper as! IPFSAuthHelper).param.uid
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let param = ["uid": uid, "path": path]
            self.authHelper?.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, param)
                }
                .done{ void in
                    Log.d(TAG(), "getChildren succeed")
                    let children = HiveChildren()
                    resolver.fulfill(children)
                    handleBy.didSucceed(children)
                }
                .catch{ error in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "getChildren falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
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
            let params = ["uid": uid,
                          "source": originPath,
                          "dest": dest]
            self.authHelper?.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, params)
                }
                .then{ json -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper!)
                }
                .then{ hash -> HivePromise<HiveVoid> in
                    return IPFSAPIs.publish(hash, self.authHelper!)
                }
                .done{ void in
                    Log.d(TAG(), "moveTo succeed")
                    resolver.fulfill(HiveVoid())
                    handleBy.didSucceed(HiveVoid())
                }
                .catch{ error in
                    let hiveError = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "moveTo falied: %s", error.localizedDescription)
                    resolver.reject(hiveError)
                    handleBy.runError(hiveError)
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
            let newPath = newPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            self.authHelper?.checkExpired()
                .then{ void -> HivePromise<String> in
                    return IPFSAPIs.getHash(originPath, self.authHelper!)
                }
                .then{ hash -> HivePromise<JSON> in
                    let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_CP.rawValue
                    let uid = (self.authHelper as! IPFSAuthHelper).param.uid
                    let params = ["uid": uid, "source": hash, "dest": newPath]
                    return IPFSAPIs.request(url, .post, params)
                }
                .then{ json -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper!)
                }
                .then{ hash -> HivePromise<HiveVoid> in
                    return IPFSAPIs.publish(hash, self.authHelper!)
                }
                .done{ success in
                    Log.d(TAG(), "copyTo succeed")
                    resolver.fulfill(HiveVoid())
                    handleBy.didSucceed(HiveVoid())
                }.catch{ error in
                    let hiveError = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "copyTo falied: %s", error.localizedDescription)
                    resolver.reject(hiveError)
                    handleBy.runError(hiveError)
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
            self.authHelper?.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, params)
                }
                .then{ hash -> HivePromise<String> in
                    return IPFSAPIs.getHash("/", self.authHelper!)
                }
                .then{ hash -> HivePromise<HiveVoid> in
                    return IPFSAPIs.publish(hash, self.authHelper!)
                }
                .done{ success in
                    Log.d(TAG(), "deleteItem succeed")
                    resolver.fulfill(success)
                    handleBy.didSucceed(success)
                }
                .catch{ error in
                    let hiveError = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "deleteItem falied: %s", error.localizedDescription)
                    resolver.reject(hiveError)
                    handleBy.runError(hiveError)
            }
        }
        return promise
    }

    override func close() {
        self.drive = nil
        self.directoryId = ""
        self.pathName = ""
        self.lastInfo = nil
        self.authHelper = nil
    }
}
