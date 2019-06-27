import Foundation
import PromiseKit
import Alamofire
@inline(__always) private func TAG() -> String { return "OneDriveDirectory" }

class OneDriveDirectory: HiveDirectoryHandle {
    var name: String?

    override init(_ info: HiveDirectoryInfo, _ authHelper: AuthHelper) {
        super.init(info, authHelper)
    }

    override func parentPathName() -> String {
        return ConvertHelper.prePath(self.pathName)
    }

    override func lastUpdatedInfo() -> HivePromise<HiveDirectoryInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryInfo>) -> HivePromise<HiveDirectoryInfo> {
        let promise = HivePromise<HiveDirectoryInfo> { resolver in
            var url = OneDriveURL.API + "/root"
            if self.pathName != "/" {
                let ecurl = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                url  = OneDriveURL.API + "/root:\(ecurl)"
            }
            self.authHelper.checkExpired()
                .then({ (void) -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .get,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(), avalidCode: 200)
                })
                .done({ (jsonData) in
                    let dirId = jsonData["id"].stringValue
                    let dic = [HiveDirectoryInfo.itemId: dirId]
                    let directoryInfo = HiveDirectoryInfo(dic)
                    self.lastInfo = directoryInfo
                    handleBy.didSucceed(directoryInfo)
                    resolver.fulfill(directoryInfo)
                    Log.e(TAG(), "Acquire directory last info succeeded: %s", directoryInfo.description)
                })
                .catch({ (error) in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "Acquiring directory last info falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
                })
        }
        return promise
    }

    override func createDirectory(withName: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withName: withName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withName: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                let params: Dictionary<String, Any> = [
                    "name": withName,
                    "folder": [: ],
                    "@microsoft.graph.conflictBehavior": "fail"]
                var url = OneDriveURL.API + "/root/children"
                if self.pathName != "/" {
                    let ecUrl = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    url = OneDriveURL.API + "/root:\(ecUrl):/children"
                }
                self.authHelper.checkExpired()
                    .then({ (void) -> HivePromise<JSON> in
                        return OneDriveHttpHelper
                            .request(url: url,
                                     method: .post,
                                     parameters: params,
                                     encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers(),
                                     avalidCode: 201)
                    })
                    .done({ (jsonData) in
                        let dirId = jsonData["id"].stringValue
                        let dic = [HiveDirectoryInfo.itemId: dirId]
                        let dirInfo = HiveDirectoryInfo(dic)
                        let dirHandle = OneDriveDirectory(dirInfo, self.authHelper)
                        dirHandle.name = jsonData["name"].string
                        var path = self.pathName + "/" + withName
                        if self.pathName ==  "/" {
                            path = self.pathName + withName
                        }
                        dirHandle.pathName = path
                        dirHandle.lastInfo = dirInfo
                        dirHandle.drive = self.drive

                        handleBy.didSucceed(dirHandle)
                        resolver.fulfill(dirHandle)
                    })
                    .catch({ (error) in
                        let error = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "Creating directory %s failed: %s", withName, error.localizedDescription)
                        resolver.reject(error)
                        handleBy.runError(error)
                    })
            }
            return promise
    }

    override func directoryHandle(atName: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atName: atName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func directoryHandle(atName: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                var path = self.pathName + "/" + atName
                if self.pathName == "/" {
                    path = self.pathName + atName
                }
                let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url = OneDriveURL.API + "/root:\(ecUrl)"
                self.authHelper.checkExpired()
                    .then({ (void) -> HivePromise<JSON> in
                        return OneDriveHttpHelper
                            .request(url: url, method: .get,
                                     parameters: nil,
                                     encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers(),
                                     avalidCode: 200)
                    })
                    .done({ (jsonData) in
                        let dirId = jsonData["id"].stringValue
                        let dic = [HiveDirectoryInfo.itemId: dirId]
                        let dirInfo = HiveDirectoryInfo(dic)
                        let dirHandle = OneDriveDirectory(dirInfo, self.authHelper)
                        dirHandle.name = jsonData["name"].string
                        dirHandle.pathName = path
                        dirHandle.lastInfo = dirInfo
                        dirHandle.drive = self.drive

                        handleBy.didSucceed(dirHandle)
                        resolver.fulfill(dirHandle)

                        Log.d(TAG(), "Acquire subdirectory %s handle succeeded.", atName)
                    })
                    .catch({ (error) in
                        let error = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "Acquiring subdirectory %s handle falied: %s", atName, error.localizedDescription)
                        resolver.reject(error)
                        handleBy.runError(error)
                    })
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
            let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url = OneDriveURL.API + "/root:\(ecUrl):/content"
            let params = ["@microsoft.graph.conflictBehavior": "fail"]
            self.authHelper.checkExpired()
                .then({ (void) -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .put,
                                 parameters: params,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(),
                                 avalidCode: 201)
                })
                .done({ (jsonData) in
                    let fileId = jsonData["id"].stringValue
                    let dic = [HiveFileInfo.itemId: fileId]
                    let fileInfo = HiveFileInfo(dic)
                    let fileHandle = OneDriveFile(fileInfo, self.authHelper)
                    fileHandle.name = jsonData["name"].string
                    fileHandle.pathName = path
                    fileHandle.drive = self.drive
                    fileHandle.lastInfo = fileInfo

                    handleBy.didSucceed(fileHandle)
                    resolver.fulfill(fileHandle)

                    Log.d(TAG(), "Creating a file %s under this directory succeeded", withName)
                })
                .catch({ (error) in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "Creating file %s falied: %s", withName, error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
                })
        }
        return promise
    }

    override func fileHandle(atName: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atName: atName, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func fileHandle(atName: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle> {
            let promise = HivePromise<HiveFileHandle> { resolver in
                var path = self.pathName + "/" + atName
                if self.pathName == "/" {
                    path = self.pathName + atName
                }
                let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url = OneDriveURL.API + "/root:\(ecUrl)"
                self.authHelper.checkExpired()
                    .then({ (void) -> HivePromise<JSON> in
                        return OneDriveHttpHelper
                            .request(url: url, method: .get,
                                     parameters: nil,
                                     encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers(),
                                     avalidCode: 200)
                    })
                    .done({ (jsonData) in
                        let fileId = jsonData["id"].stringValue
                        let dic = [HiveFileInfo.itemId: fileId]
                        let fileInfo = HiveFileInfo(dic)
                        let fileHandle = OneDriveFile(fileInfo, self.authHelper)
                        fileHandle.name = jsonData["name"].string
                        fileHandle.pathName = path
                        fileHandle.drive = self.drive
                        fileHandle.lastInfo = fileInfo

                        handleBy.didSucceed(fileHandle)
                        resolver.fulfill(fileHandle)

                        Log.d(TAG(), "Acquire file %s handle succeeded.", atName)
                    })
                    .catch({ (error) in
                        let error = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "Acquiring file %s handle falied: %s", atName, error.localizedDescription)
                        resolver.reject(error)
                        handleBy.runError(error)
                    })
            }
            return promise
    }

    override func getChildren() -> HivePromise<HiveChildren> {
        return getChildren(handleBy: HiveCallback<HiveChildren>())
    }

    override func getChildren(handleBy: HiveCallback<HiveChildren>) -> HivePromise<HiveChildren> {
        let promise = HivePromise<HiveChildren> { resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var url = "\(OneDriveURL.API)/root:\(path):/children"
            if self.pathName == "/" {
                url = "\(OneDriveURL.API)/root/children"
            }
            self.authHelper.checkExpired()
                .then({ (void) -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .get,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(),
                                 avalidCode: 200)
                })
                .done({ (jsonData) in
                    let children = HiveChildren()
                    // todo
                    children.installValue(jsonData)
                    handleBy.didSucceed(children)
                    resolver.fulfill(children)
                })
                .catch({ (error) in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "Acquiring children infos under this directory falied: %s", error.localizedDescription)
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
        let promise = HivePromise<HiveVoid>{ resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url = "\(OneDriveURL.API)\(ONEDRIVE_ROOTDIR):\(path)"
            let params: Dictionary<String, Any> = [
                "parentReference": ["path": "/drive/root:" + newPath],
                "name": self.name!,
                "@microsoft.graph.conflictBehavior": "fail"]
            self.authHelper.checkExpired()
                .then({ (void) -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .patch,
                                 parameters: params,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(),
                                 avalidCode: 200)
                })
                .done({ (jsonData) in
                    resolver.fulfill(HiveVoid())
                    handleBy.didSucceed(HiveVoid())
                })
                .catch({ (error) in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "Moving this directory to %s failed: %s", newPath, error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
                })
        }
        return promise
    }

    override func copyTo(newPath: String) -> HivePromise<HiveVoid> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<HiveVoid>())
    }

    override func copyTo(newPath: String, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid>{ resolver in
            let path = ("/" + self.pathName).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var url = OneDriveURL.API + ONEDRIVE_ROOTDIR + ":" + path + ":/copy"
            if newPath == "/" {
                url = OneDriveURL.API + ONEDRIVE_ROOTDIR + "/copy"
            }
            let params: Dictionary<String, Any> = [
                "parentReference" : ["path": "/drive/root:\(newPath)"],
                "name": self.name as Any,
                "@microsoft.graph.conflictBehavior": "fail"]
            self.authHelper.checkExpired()
                .then({ (void) -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .post,
                                 parameters: params,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(),
                                 avalidCode: 202)
                })
                .then({ (jsonData) -> HivePromise<HiveVoid> in
                    let urlString = jsonData["Location"].stringValue
                    return OneDriveHttpHelper.pollingCopyresult(urlString)
                })
                .done({ (void) in
                    resolver.fulfill(HiveVoid())
                    handleBy.didSucceed(HiveVoid())
                    Log.d(TAG(), "copyTo this directory to %s succeeded", newPath)
                })
                .catch({ (error) in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "Copying this directory to %s falied: %s", newPath, error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
                })
        }
        return promise
    }

    override func deleteItem() -> HivePromise<HiveVoid> {
        return deleteItem(handleBy: HiveCallback<HiveVoid>())
    }

    override func deleteItem(handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid>{ resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(ONEDRIVE_ROOTDIR):/\(path)"
            self.authHelper.checkExpired()
                .then({ (void) -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .delete,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(),
                                 avalidCode: 204)
                })
                .done({ (jsonData) in
                    self.pathName = ""
                    self.drive = nil
                    self.directoryId = ""
                    self.lastInfo = nil
                    resolver.fulfill(HiveVoid())
                    handleBy.didSucceed(HiveVoid())
                    Log.e(TAG(), "Delete the directory item succeeded")
                })
                .catch({ (error) in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "Delete this directory item failed: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
                })
        }
        return promise
    }

    override func close() {
        // TODO
    }

}
