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
        let promise: HivePromise = HivePromise<HiveDirectoryInfo> { resolver in
            var url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT)"
            if self.pathName != "/" {
                let ecurl: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                url  = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(ecurl)"
            }
            self.authHelper!.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveAPIs
                        .request(url: url, method: .get,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper!),
                                 avalidCode: 200, self.authHelper!)
                }
                .done{ jsonData in
                    let dirId: String = jsonData["id"].stringValue
                    let folder: JSON = JSON(jsonData["folder"])
                    let dic: Dictionary<String, String> = [HiveDirectoryInfo.itemId: dirId,
                               HiveDirectoryInfo.name: jsonData["name"].stringValue,
                               HiveDirectoryInfo.childCount: String(folder["childCount"].intValue)]
                    let directoryInfo: HiveDirectoryInfo = HiveDirectoryInfo(dic)
                    self.lastInfo = directoryInfo
                    handleBy.didSucceed(directoryInfo)
                    resolver.fulfill(directoryInfo)
                    Log.e(TAG(), "Acquire directory last info succeeded: \( directoryInfo.description)")
                }
                .catch{ error in
                    Log.e(TAG(), "Acquiring directory last info falied: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func createDirectory(withName: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withName: withName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withName: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
            let promise: HivePromise = HivePromise<HiveDirectoryHandle> { resolver in
                let params: Dictionary<String, Any> = [
                    "name": withName,
                    "folder": [: ],
                    "@microsoft.graph.conflictBehavior": "fail"]
                var url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT)/children"
                if self.pathName != "/" {
                    let ecUrl: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    url = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(ecUrl):/children"
                }
                self.authHelper!.checkExpired()
                    .then{ void -> HivePromise<JSON> in
                        return OneDriveAPIs
                            .request(url: url,
                                     method: .post,
                                     parameters: params,
                                     encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers(self.authHelper!),
                                     avalidCode: 201, self.authHelper!)
                    }
                    .done{ jsonData in
                        let dirId: String = jsonData["id"].stringValue
                        let dic: Dictionary<String, String> = [HiveDirectoryInfo.itemId: dirId,
                                   HiveDirectoryInfo.name: jsonData["name"].stringValue,
                                   HiveDirectoryInfo.childCount: "0"]
                        let dirInfo: HiveDirectoryInfo = HiveDirectoryInfo(dic)
                        let dirHandle: OneDriveDirectory = OneDriveDirectory(dirInfo, self.authHelper!)
                        dirHandle.name = jsonData["name"].string
                        var path: String = "\(self.pathName)/\(withName)"
                        if self.pathName ==  "/" {
                            path = "\(self.pathName )\(withName)"
                        }
                        dirHandle.pathName = path
                        dirHandle.lastInfo = dirInfo
                        dirHandle.drive = self.drive

                        handleBy.didSucceed(dirHandle)
                        resolver.fulfill(dirHandle)
                        Log.d(TAG(), "Creating a directory %s under this directory succeeded: \(withName)")
                    }
                    .catch{ error in
                        Log.e(TAG(), "Creating directory %s failed: \(withName)\(HiveError.des(error as! HiveError))")
                        handleBy.runError(error as! HiveError)
                        resolver.reject(error)
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
                var path: String = "\(self.pathName)/\(atName)"
                if self.pathName == "/" {
                    path = "\(self.pathName)\(atName)"
                }
                let ecUrl: String = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url: String = OneDriveURL.API + "\(OneDriveURL.ROOT):\(ecUrl)"
                self.authHelper!.checkExpired()
                    .then{ void -> HivePromise<JSON> in
                        return OneDriveAPIs
                            .request(url: url, method: .get,
                                     parameters: nil,
                                     encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers(self.authHelper!),
                                     avalidCode: 200, self.authHelper!)
                    }
                    .done{ jsonData in
                        let dirId: String = jsonData["id"].stringValue
                        let folder: JSON = JSON(jsonData["folder"])
                        let dic: Dictionary<String, String> = [HiveDirectoryInfo.itemId: dirId,
                                   HiveDirectoryInfo.name: jsonData["name"].stringValue,
                                   HiveDirectoryInfo.childCount: String(folder["childCount"].intValue)]
                        let dirInfo: HiveDirectoryInfo = HiveDirectoryInfo(dic)
                        let dirHandle: OneDriveDirectory = OneDriveDirectory(dirInfo, self.authHelper!)
                        dirHandle.name = jsonData["name"].string
                        dirHandle.pathName = path
                        dirHandle.lastInfo = dirInfo
                        dirHandle.drive = self.drive

                        handleBy.didSucceed(dirHandle)
                        resolver.fulfill(dirHandle)

                        Log.d(TAG(), "Acquire subdirectory %s handle succeeded: \(atName)")
                    }
                    .catch{ error in
                        Log.e(TAG(), "Acquiring subdirectory %s handle falied: \(atName)\(HiveError.des(error as! HiveError))")
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
        let promise = HivePromise<HiveFileHandle> { resolver in
            var path = "\(self.pathName)/\(withName)"
            if self.pathName == "/" {
                path = "\(self.pathName)\(withName)"
            }
            let ecUrl: String = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = OneDriveURL.API + "\(OneDriveURL.ROOT):\(ecUrl):/content?@microsoft.graph.conflictBehavior=fail"
            self.authHelper!.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveAPIs
                        .request(url: url, method: .put,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper!),
                                 avalidCode: 201, self.authHelper!)
                }
                .done{ jsonData in
                    let fileId: String = jsonData["id"].stringValue
                    let dic: Dictionary<String, String> = [HiveFileInfo.itemId: fileId,
                               HiveFileInfo.name: jsonData["name"].stringValue,
                               HiveFileInfo.size: "0"]
                    let fileInfo: HiveFileInfo = HiveFileInfo(dic)
                    let fileHandle: OneDriveFile = OneDriveFile(fileInfo, self.authHelper!)
                    fileHandle.name = jsonData["name"].string
                    fileHandle.pathName = path
                    fileHandle.drive = self.drive
                    fileHandle.lastInfo = fileInfo

                    handleBy.didSucceed(fileHandle)
                    resolver.fulfill(fileHandle)

                    Log.d(TAG(), "Creating a file %s under this directory succeeded: \(withName)")
                }
                .catch{ error in
                    Log.e(TAG(), "Creating file %s falied: \(withName)\(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
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
                var path = "\(self.pathName)/\(atName)"
                if self.pathName == "/" {
                    path = "\(self.pathName)\(atName)"
                }
                let ecUrl: String = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url: String = OneDriveURL.API + "\(OneDriveURL.ROOT):\(ecUrl)"
                self.authHelper!.checkExpired()
                    .then{ void -> HivePromise<JSON> in
                        return OneDriveAPIs
                            .request(url: url, method: .get,
                                     parameters: nil,
                                     encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers(self.authHelper!),
                                     avalidCode: 200, self.authHelper!)
                    }
                    .done{ jsonData in
                        let fileId: String = jsonData["id"].stringValue
                        let dic: Dictionary<String, String> = [HiveFileInfo.itemId: fileId,
                                   HiveFileInfo.name: jsonData["name"].stringValue,
                                   HiveFileInfo.size: String(jsonData["size"].int64Value)]
                        let fileInfo: HiveFileInfo = HiveFileInfo(dic)
                        let fileHandle: OneDriveFile = OneDriveFile(fileInfo, self.authHelper!)
                        fileHandle.name = jsonData["name"].string
                        fileHandle.pathName = path
                        fileHandle.drive = self.drive
                        fileHandle.lastInfo = fileInfo

                        handleBy.didSucceed(fileHandle)
                        resolver.fulfill(fileHandle)

                        Log.d(TAG(), "Acquire file %s handle succeeded: \(atName)")
                    }
                    .catch{ error in
                        Log.e(TAG(), "Acquiring file %s handle falied: \(atName)\(HiveError.des(error as! HiveError))")
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
        let promise = HivePromise<HiveChildren> { resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var url = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/children"
            if self.pathName == "/" {
                url = "\(OneDriveURL.API)\(OneDriveURL.ROOT)/children"
            }
            self.authHelper!.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveAPIs
                        .request(url: url, method: .get,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper!),
                                 avalidCode: 200, self.authHelper!)
                }
                .done{ jsonData in
                    let children: HiveChildren = HiveChildren()
                    children.installValue(jsonData["value"], .oneDrive)
                    handleBy.didSucceed(children)
                    resolver.fulfill(children)
                    Log.e(TAG(), "Acquiring children infos under this directory succeeded:")
                }
                .catch{ error in
                    Log.e(TAG(), "Acquiring children infos under this directory falied: \(HiveError.des(error as! HiveError))")
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
        let promise = HivePromise<Void>{ resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path)"
            let params: Dictionary<String, Any> = [
                "parentReference": ["path": "/drive/root:\(newPath)"],
                "name": self.name!,
                "@microsoft.graph.conflictBehavior": "fail"]
            self.authHelper!.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveAPIs
                        .request(url: url, method: .patch,
                                 parameters: params,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper!),
                                 avalidCode: 200, self.authHelper!)
                }
                .done{ jsonData in
                    handleBy.didSucceed(Void())
                    resolver.fulfill(Void())
                    Log.e(TAG(), "Moving this directory to %s succeeded: \(newPath)")
                }
                .catch{ error in
                    Log.e(TAG(), "Moving this directory to %s failed: \(newPath)\(HiveError.des(error as! HiveError))")
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
        let promise = HivePromise<Void>{ resolver in
            let path: String = "/\(self.pathName)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var url = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/copy"
            if newPath == "/" {
                url = "\(OneDriveURL.API)\(OneDriveURL.ROOT)/copy"
            }
            let params: Dictionary<String, Any> = [
                "parentReference" : ["path": "/drive/root:\(newPath)"],
                "name": self.name as Any,
                "@microsoft.graph.conflictBehavior": "fail"]
            self.authHelper!.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveAPIs
                        .request(url: url, method: .post,
                                 parameters: params,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper!),
                                 avalidCode: statusCode.accepted.rawValue, self.authHelper!)
                }
                .then{ jsonData -> HivePromise<Void> in
                    let urlString: String = jsonData["Location"].stringValue
                    return OneDriveAPIs.pollingCopyresult(urlString)
                }
                .done{ void in
                    handleBy.didSucceed(Void())
                    resolver.fulfill(Void())
                    Log.d(TAG(), "copyTo this directory to %s succeeded: \(newPath)")
                }
                .catch{ error in
                    Log.e(TAG(), "Copying this directory to %s falied: \(newPath)\(HiveError.des(error as! HiveError))")
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
        let promise = HivePromise<Void>{ resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):/\(path)"
            self.authHelper!.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveAPIs
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
                    handleBy.didSucceed(Void())
                    resolver.fulfill(Void())
                    Log.e(TAG(), "Delete the directory item succeeded")
                }
                .catch{ error in
                    Log.e(TAG(), "Delete this directory item failed: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

}
