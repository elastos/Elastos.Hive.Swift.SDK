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
        return PathExtracter(pathName).dirNamePart()
    }

    override func lastUpdatedInfo() -> HivePromise<HiveDirectoryInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryInfo>) -> HivePromise<HiveDirectoryInfo> {
        let promise = HivePromise<HiveDirectoryInfo> { resolver in
            var url = OneDriveURL.API + OneDriveURL.ROOT
            if self.pathName != "/" {
                let ecurl = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                url  = OneDriveURL.API + "\(OneDriveURL.ROOT):\(ecurl)"
            }
            self.authHelper!.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .get,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper!),
                                 avalidCode: 200, self.authHelper!)
                }
                .done{ jsonData in
                    let dirId = jsonData["id"].stringValue
                    let folder = JSON(jsonData["folder"])
                    let dic = [HiveDirectoryInfo.itemId: dirId,
                               HiveDirectoryInfo.name: jsonData["name"].stringValue,
                               HiveDirectoryInfo.childCount: String(folder["childCount"].intValue)]
                    let directoryInfo = HiveDirectoryInfo(dic)
                    self.lastInfo = directoryInfo
                    handleBy.didSucceed(directoryInfo)
                    resolver.fulfill(directoryInfo)
                    Log.e(TAG(), "Acquire directory last info succeeded: " + directoryInfo.description)
                }
                .catch{ error in
                    Log.e(TAG(), "Acquiring directory last info falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
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
                var url = OneDriveURL.API + "\(OneDriveURL.ROOT)/children"
                if self.pathName != "/" {
                    let ecUrl = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    url = OneDriveURL.API + "\(OneDriveURL.ROOT):\(ecUrl):/children"
                }
                self.authHelper!.checkExpired()
                    .then{ void -> HivePromise<JSON> in
                        return OneDriveHttpHelper
                            .request(url: url,
                                     method: .post,
                                     parameters: params,
                                     encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers(self.authHelper!),
                                     avalidCode: 201, self.authHelper!)
                    }
                    .done{ jsonData in
                        let dirId = jsonData["id"].stringValue
                        let dic = [HiveDirectoryInfo.itemId: dirId,
                                   HiveDirectoryInfo.name: jsonData["name"].stringValue,
                                   HiveDirectoryInfo.childCount: "0"]
                        let dirInfo = HiveDirectoryInfo(dic)
                        let dirHandle = OneDriveDirectory(dirInfo, self.authHelper!)
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
                    }
                    .catch{ error in
                        Log.e(TAG(), "Creating directory %s failed: " + withName + HiveError.des(error as! HiveError))
                        resolver.reject(error)
                        handleBy.runError(error as! HiveError)
                }
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
                let url = OneDriveURL.API + "\(OneDriveURL.ROOT):\(ecUrl)"
                self.authHelper!.checkExpired()
                    .then{ void -> HivePromise<JSON> in
                        return OneDriveHttpHelper
                            .request(url: url, method: .get,
                                     parameters: nil,
                                     encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers(self.authHelper!),
                                     avalidCode: 200, self.authHelper!)
                    }
                    .done{ jsonData in
                        let dirId = jsonData["id"].stringValue
                        let folder = JSON(jsonData["folder"])
                        let dic = [HiveDirectoryInfo.itemId: dirId,
                                   HiveDirectoryInfo.name: jsonData["name"].stringValue,
                                   HiveDirectoryInfo.childCount: String(folder["childCount"].intValue)]
                        let dirInfo = HiveDirectoryInfo(dic)
                        let dirHandle = OneDriveDirectory(dirInfo, self.authHelper!)
                        dirHandle.name = jsonData["name"].string
                        dirHandle.pathName = path
                        dirHandle.lastInfo = dirInfo
                        dirHandle.drive = self.drive

                        handleBy.didSucceed(dirHandle)
                        resolver.fulfill(dirHandle)

                        Log.d(TAG(), "Acquire subdirectory %s handle succeeded.", atName)
                    }
                    .catch{ error in
                        Log.e(TAG(), "Acquiring subdirectory %s handle falied: " + atName + HiveError.des(error as! HiveError))
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
            let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url = OneDriveURL.API + "\(OneDriveURL.ROOT):\(ecUrl):/content?@microsoft.graph.conflictBehavior=fail"
            self.authHelper!.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .put,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper!),
                                 avalidCode: 201, self.authHelper!)
                }
                .done{ jsonData in
                    let fileId = jsonData["id"].stringValue
                    let dic = [HiveFileInfo.itemId: fileId,
                               HiveFileInfo.name: jsonData["name"].stringValue,
                               HiveFileInfo.size: "0"]
                    let fileInfo = HiveFileInfo(dic)
                    let fileHandle = OneDriveFile(fileInfo, self.authHelper!)
                    fileHandle.name = jsonData["name"].string
                    fileHandle.pathName = path
                    fileHandle.drive = self.drive
                    fileHandle.lastInfo = fileInfo

                    handleBy.didSucceed(fileHandle)
                    resolver.fulfill(fileHandle)

                    Log.d(TAG(), "Creating a file %s under this directory succeeded", withName)
                }
                .catch{ error in
                    Log.e(TAG(), "Creating file %s falied: " + withName + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
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
                let url = OneDriveURL.API + "\(OneDriveURL.ROOT):\(ecUrl)"
                self.authHelper!.checkExpired()
                    .then{ void -> HivePromise<JSON> in
                        return OneDriveHttpHelper
                            .request(url: url, method: .get,
                                     parameters: nil,
                                     encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers(self.authHelper!),
                                     avalidCode: 200, self.authHelper!)
                    }
                    .done{ jsonData in
                        let fileId = jsonData["id"].stringValue
                        let dic = [HiveFileInfo.itemId: fileId,
                                   HiveFileInfo.name: jsonData["name"].stringValue,
                                   HiveFileInfo.size: String(jsonData["size"].intValue)]
                        let fileInfo = HiveFileInfo(dic)
                        let fileHandle = OneDriveFile(fileInfo, self.authHelper!)
                        fileHandle.name = jsonData["name"].string
                        fileHandle.pathName = path
                        fileHandle.drive = self.drive
                        fileHandle.lastInfo = fileInfo

                        handleBy.didSucceed(fileHandle)
                        resolver.fulfill(fileHandle)

                        Log.d(TAG(), "Acquire file %s handle succeeded.", atName)
                    }
                    .catch{ error in
                        Log.e(TAG(), "Acquiring file %s handle falied: " + atName + HiveError.des(error as! HiveError))
                        resolver.reject(error)
                        handleBy.runError(error as! HiveError)
                }
            }
            return promise
    }

    override func getChildren() -> HivePromise<HiveChildren> {
        return getChildren(handleBy: HiveCallback<HiveChildren>())
    }

    override func getChildren(handleBy: HiveCallback<HiveChildren>) -> HivePromise<HiveChildren> {
        let promise = HivePromise<HiveChildren> { resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var url = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/children"
            if self.pathName == "/" {
                url = "\(OneDriveURL.API)\(OneDriveURL.ROOT)/children"
            }
            self.authHelper!.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .get,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper!),
                                 avalidCode: 200, self.authHelper!)
                }
                .done{ jsonData in
                    let children = HiveChildren()
                    children.installValue(jsonData)
                    handleBy.didSucceed(children)
                    resolver.fulfill(children)
                }
                .catch{ error in
                    Log.e(TAG(), "Acquiring children infos under this directory falied: " + HiveError.des(error as! HiveError))
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
        let promise = HivePromise<HiveVoid>{ resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path)"
            let params: Dictionary<String, Any> = [
                "parentReference": ["path": "/drive/root:" + newPath],
                "name": self.name!,
                "@microsoft.graph.conflictBehavior": "fail"]
            self.authHelper!.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .patch,
                                 parameters: params,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper!),
                                 avalidCode: 200, self.authHelper!)
                }
                .done{ jsonData in
                    resolver.fulfill(HiveVoid())
                    handleBy.didSucceed(HiveVoid())
                }
                .catch{ error in
                    Log.e(TAG(), "Moving this directory to %s failed: " + newPath + HiveError.des(error as! HiveError))
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
        let promise = HivePromise<HiveVoid>{ resolver in
            let path = ("/" + self.pathName).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var url = OneDriveURL.API + OneDriveURL.ROOT + ":" + path + ":/copy"
            if newPath == "/" {
                url = OneDriveURL.API + OneDriveURL.ROOT + "/copy"
            }
            let params: Dictionary<String, Any> = [
                "parentReference" : ["path": "/drive/root:\(newPath)"],
                "name": self.name as Any,
                "@microsoft.graph.conflictBehavior": "fail"]
            self.authHelper!.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .post,
                                 parameters: params,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper!),
                                 avalidCode: statusCode.accepted.rawValue, self.authHelper!)
                }
                .then{ jsonData -> HivePromise<HiveVoid> in
                    let urlString = jsonData["Location"].stringValue
                    return OneDriveHttpHelper.pollingCopyresult(urlString)
                }
                .done{ void in
                    resolver.fulfill(HiveVoid())
                    handleBy.didSucceed(HiveVoid())
                    Log.d(TAG(), "copyTo this directory to %s succeeded", newPath)
                }
                .catch{ error in
                    Log.e(TAG(), "Copying this directory to %s falied: " + newPath + HiveError.des(error as! HiveError))
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
        let promise = HivePromise<HiveVoid>{ resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):/\(path)"
            self.authHelper!.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .delete,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper!),
                                 avalidCode: statusCode.delete.rawValue, self.authHelper!)
                }
                .done{ jsonData in
                    self.pathName = ""
                    self.drive = nil
                    self.directoryId = ""
                    self.lastInfo = nil
                    resolver.fulfill(HiveVoid())
                    handleBy.didSucceed(HiveVoid())
                    Log.e(TAG(), "Delete the directory item succeeded")
                }
                .catch{ error in
                    Log.e(TAG(), "Delete this directory item failed: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }

    override func close() {
        self.name = nil
        self.drive = nil
        self.directoryId = ""
        self.pathName = ""
        self.lastInfo = nil
        self.authHelper = nil
    }

}
