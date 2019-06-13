

import Foundation
import Alamofire
import PromiseKit

class HiveIpfsDirectory: HiveDirectoryHandle {

    override init(_ info: HiveDirectoryInfo, _ authHelper: AuthHelper) {
        super.init(info, authHelper)
    }

    override func parentPathName() -> String {
        return HelperMethods.prePath(self.pathName)
    }

    override func lastUpdatedInfo() -> HivePromise<HiveDirectoryInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryInfo>) -> HivePromise<HiveDirectoryInfo> {
        let promise = HivePromise<HiveDirectoryInfo> { resolver in
            _ = "TODO"
        }
        return promise
    }

    override func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        let promise = HivePromise<HiveDirectoryHandle> { resolver in
            _ = self.authHelper.checkExpired().done({ (success) in

                var path = self.pathName + "/" + withPath
                if self.pathName == "/" {
                    path = self.pathName + withPath
                }
                HiveIpfsApis.createDirectory(path).then({ (json) -> HivePromise<Bool> in
                    return HiveIpfsApis.publish(path)
                }).done({ (success) in
                    let dirId = "TODO"
                    let directoryInfo = HiveDirectoryInfo(dirId)
                    let directoryHandle = HiveIpfsDirectory(directoryInfo, self.authHelper)
                    directoryHandle.lastInfo = directoryInfo
                    directoryHandle.pathName = path
                    directoryHandle.drive = self.drive
                    resolver.fulfill(directoryHandle)
                    handleBy.didSucceed(directoryHandle)
                }).catch({ (error) in
                    let hiveError = HiveError.failue(des: error.localizedDescription)
                    resolver.reject(hiveError)
                })
            })
        }
        return promise
    }

    override func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        let promise = HivePromise<HiveDirectoryHandle> { resolver in
            _ = self.authHelper.checkExpired().done({ (success) in

                let url = HiveIpfsURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
                let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
                var path = self.pathName + "/" + atPath
                if self.pathName == "/" {
                    path = self.pathName + atPath
                }
                let param = ["uid": uid, "path": path]
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
                        let directoryInfo = HiveDirectoryInfo(uid)
                        let directoryHandle = HiveIpfsDirectory(directoryInfo, self.authHelper)
                        directoryHandle.lastInfo = directoryInfo
                        directoryHandle.pathName = path
                        directoryHandle.drive = self.drive
                        resolver.fulfill(directoryHandle)
                        handleBy.didSucceed(directoryHandle)
                    })
            })
        }
        return promise
    }

    override func createFile(withPath: String) -> HivePromise<HiveFileHandle> {
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        let promise = HivePromise<HiveFileHandle> { resolver in
            _ = self.authHelper.checkExpired().done({ (success) in

                var path = self.pathName + "/" + withPath
                if self.pathName == "/" {
                    path = self.pathName + withPath
                }
                HiveIpfsApis.creatFile(path).then({ (json) -> HivePromise<Bool> in
                    return HiveIpfsApis.publish(path)
                }).done({ (success) in
                    let fileId = "TODO"
                    let fileInfo = HiveFileInfo(fileId)
                    let fileHandle = HiveIpfsFile(fileInfo, self.authHelper)
                    fileHandle.pathName = path
                    fileHandle.lastInfo = fileInfo
                    fileHandle.drive = self.drive
                    handleBy.didSucceed(fileHandle)
                    resolver.fulfill(fileHandle)
                }).catch({ (error) in
                    let hiveError = HiveError.failue(des: error.localizedDescription)
                    handleBy.runError(hiveError)
                    resolver.reject(hiveError)
                })
            })
        }
        return promise
    }

    override func fileHandle(atPath: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        let promise = HivePromise<HiveFileHandle> { resolver in
            _ = self.authHelper.checkExpired().done({ (success) in

                let url = HiveIpfsURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
                let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
                var path = self.pathName + "/" + atPath
                if self.pathName == "/" {
                    path = self.pathName + atPath
                }
                let param = ["uid": uid, "path": path]
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
                        let fileInfo = HiveFileInfo(uid)
                        let fileHandle = HiveIpfsFile(fileInfo, self.authHelper)
                        fileHandle.lastInfo = fileInfo
                        fileHandle.pathName = path
                        fileHandle.drive = self.drive
                        resolver.fulfill(fileHandle)
                        handleBy.didSucceed(fileHandle)
                    })
            })
        }
        return promise
    }

    override func getChildren() -> HivePromise<HiveChildren> {
        return getChildren(handleBy: HiveCallback<HiveChildren>())
    }

    override func getChildren(handleBy: HiveCallback<HiveChildren>) -> HivePromise<HiveChildren> {
        let promise = HivePromise<HiveChildren> { resolver in
            _ = self.authHelper.checkExpired().done({ (success) in

                let url = HiveIpfsURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_LS.rawValue
                let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
                let path = self.pathName
                let param = ["uid": uid, "path": path]
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
                        let jsonData = JSON(dataResponse.result.value as Any)
                        let children = HiveChildren()
                        children.installValue(jsonData)
                        resolver.fulfill(children)
                        handleBy.didSucceed(children)
                    })
            })
        }
        return promise
    }

    override func moveTo(newPath: String) -> HivePromise<Bool> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            _ = self.authHelper.checkExpired().done({ (success) in

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
            })
        }
        return promise
    }

    override func copyTo(newPath: String) -> HivePromise<Bool> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            _ = self.authHelper.checkExpired().done({ (success) in

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
            })
        }
        return promise
    }

    override func deleteItem() -> HivePromise<Bool> {
        return deleteItem(handleBy: HiveCallback<Bool>())
    }

    override func deleteItem(handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            _ = self.authHelper.checkExpired().done({ (success) in

                HiveIpfsApis.deleteItem(self.pathName).then({ (success) -> HivePromise<Bool> in
                    return HiveIpfsApis.publish("/")
                }).done({ (success) in
                    resolver.fulfill(success)
                }).catch({ (error) in
                    let hiveError = HiveError.failue(des: error.localizedDescription)
                    resolver.reject(hiveError)
                    handleBy.runError(hiveError)
                })
            })
        }
        return promise
    }

    override func close() {
        _ = "TODO"
    }


    
}
