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

@inline(__always) private func TAG() -> String { return "OneDriveDrive" }

 class OneDriveDrive: HiveDriveHandle {
    private var authHelper: OneDriveAuthHelper
    internal static var oneDriveInstance: HiveDriveHandle?
    var param: OneDriveParameter?

    init(_ info: HiveDriveInfo, _ authHelper: AuthHelper) {
        self.authHelper = authHelper as! OneDriveAuthHelper
        super.init(.oneDrive, info)
        OneDriveDrive.oneDriveInstance = self
    }

    static func sharedInstance() -> OneDriveDrive {
        return oneDriveInstance as! OneDriveDrive
    }

    override public func lastUpdatedInfo() -> HivePromise<HiveDriveInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>())
    }

    override public func lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>) -> HivePromise<HiveDriveInfo> {
        return HivePromise<HiveDriveInfo> { resolver in
            self.authHelper.checkExpired().then { void -> HivePromise<JSON> in
                return OneDriveAPIs.request(url:"\(OneDriveURL.API)",
                             method: .get, parameters: nil,
                             encoding: JSONEncoding.default,
                             headers: OneDriveHttpHeader.headers(self.authHelper),
                             avalidCode: 200, self.authHelper)
            }.done { jsonData in
                let dict:  Dictionary<String, String> = [HiveDriveInfo.driveId: jsonData["id"].stringValue]
                let driveInfo: HiveDriveInfo = HiveDriveInfo(dict)
                self.lastInfo = driveInfo

                Log.d(TAG(), "Acquiring last drive information succeeeded (info: \(driveInfo.attrDic!.description)")
                handleBy.didSucceed(driveInfo)
                resolver.fulfill(driveInfo)
            }.catch { error in
                Log.e(TAG(), "Acquiring last drive information falied: \(HiveError.des(error as! HiveError))")
                handleBy.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    override public func rootDirectoryHandle() -> HivePromise<HiveDirectoryHandle> {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override public func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>)  -> HivePromise<HiveDirectoryHandle> {
        return HivePromise<HiveDirectoryHandle> { resolver in
            self.authHelper.checkExpired().then { void -> HivePromise<JSON> in
                return OneDriveAPIs.request(url: "\(OneDriveURL.API)\(OneDriveURL.ROOT)",
                            method: .get,parameters: nil,
                            encoding: JSONEncoding.default,
                            headers: OneDriveHttpHeader.headers(self.authHelper),
                            avalidCode: 200, self.authHelper)
            }.done { jsonData in
                let folder: JSON = JSON(jsonData["folder"])
                let dict: Dictionary<String, String> = [
                            HiveDirectoryInfo.itemId: jsonData["id"].stringValue,
                            HiveDirectoryInfo.name: "/",
                            HiveDirectoryInfo.childCount: String(folder["childCount"].intValue)]
                let dirInfo: HiveDirectoryInfo = HiveDirectoryInfo(dict)
                let dirHandle: OneDriveDirectory = OneDriveDirectory(dirInfo, self.authHelper)

                dirHandle.name = jsonData["id"].stringValue
                dirHandle.pathName = "/"
                dirHandle.drive = self
                dirHandle.lastInfo = dirInfo

                Log.d(TAG(), "Acquiring root directory instance success")
                handleBy.didSucceed(dirHandle)
                resolver.fulfill(dirHandle)
            }.catch { error in
                Log.e(TAG(), "Acquiring root directory instance falied: \(HiveError.des(error as! HiveError))")
                handleBy.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    override public func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override public func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        return HivePromise<HiveDirectoryHandle> { resolver in
            let params: Dictionary<String, Any> = [
                    "name": PathExtracter(withPath).baseNamePart(),
                    "folder": [: ],
                    "@microsoft.graph.conflictBehavior": "fail"]
            let path = PathExtracter(withPath).dirNamePart()
            let url = OneDriveURL(path, "children").compose()

            self.authHelper.checkExpired().then { void -> HivePromise<JSON> in
                return OneDriveAPIs.request(url: url,
                            method: .post,
                            parameters: params,
                            encoding: JSONEncoding.default,
                            headers: OneDriveHttpHeader.headers(self.authHelper),
                            avalidCode: statusCode.created.rawValue, self.authHelper)
            }.done { jsonData in
                let dict: Dictionary<String, String> = [
                            HiveDirectoryInfo.itemId: jsonData["id"].stringValue,
                            HiveDirectoryInfo.name: jsonData["name"].stringValue,
                            HiveDirectoryInfo.childCount: "0"]
                let dirInfo: HiveDirectoryInfo = HiveDirectoryInfo(dict)
                let dirHandle: OneDriveDirectory = OneDriveDirectory(dirInfo, self.authHelper)

                dirHandle.name = jsonData["name"].string
                dirHandle.pathName = withPath
                dirHandle.drive = self
                dirHandle.lastInfo = dirInfo

                Log.d(TAG(), "Directory %s has been created successfully: \(withPath)")
                handleBy.didSucceed(dirHandle)
                resolver.fulfill(dirHandle)
            }.catch{ error in
                Log.e(TAG(), "createDirectory falied: \(HiveError.des(error as! HiveError))")
                handleBy.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    override public func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override public func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) -> HivePromise<HiveDirectoryHandle> {
        return HivePromise<HiveDirectoryHandle> { resolver in
            self.authHelper.checkExpired().then { void -> HivePromise<JSON> in
                return OneDriveAPIs.request(url: OneDriveURL(atPath).compose(),
                            method: .get, parameters: nil,
                            encoding: JSONEncoding.default,
                            headers: OneDriveHttpHeader.headers(self.authHelper),
                            avalidCode: 200, self.authHelper)
            }.done { jsonData in
                let folder: JSON = JSON(jsonData["folder"])
                let dict: Dictionary<String, String> = [
                            HiveDirectoryInfo.itemId: jsonData["id"].stringValue,
                            HiveDirectoryInfo.name: jsonData["name"].stringValue,
                            HiveDirectoryInfo.childCount: String(folder["childCount"].intValue)]
                let dirInfo: HiveDirectoryInfo = HiveDirectoryInfo(dict)
                let dirHandle: OneDriveDirectory = OneDriveDirectory(dirInfo, self.authHelper)

                dirHandle.name = jsonData["name"].stringValue
                dirHandle.pathName = atPath
                dirHandle.drive = self
                dirHandle.lastInfo = dirInfo

                Log.d(TAG(), "Acquiring directory %s instance succeeded: \(atPath)")
                handleBy.didSucceed(dirHandle)
                resolver.fulfill(dirHandle)
            }.catch { error in
                Log.e(TAG(), "Acquiring directory %s instance failed: \(atPath)\(HiveError.des(error as! HiveError))")
                handleBy.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    override public func createFile(withPath: String) -> HivePromise<HiveFileHandle> {
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override public func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        return HivePromise<HiveFileHandle> { resolver in
            self.authHelper.checkExpired().then { void -> HivePromise<JSON> in
                let ecUrl = withPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                return OneDriveAPIs.request(url:"\(OneDriveURL.API)\(OneDriveURL.ROOT):\(ecUrl):/content?@microsoft.graph.conflictBehavior=fail",
                            method: .put, parameters: nil,
                            encoding: JSONEncoding.default,
                            headers: OneDriveHttpHeader.headers(self.authHelper),
                            avalidCode: statusCode.created.rawValue, self.authHelper)
            }.done { jsonData in
                let dict: Dictionary<String, String> = [
                            HiveFileInfo.itemId: jsonData["id"].stringValue,
                            HiveFileInfo.name: jsonData["name"].stringValue,
                            HiveFileInfo.size: "0"]
                let fileInfo: HiveFileInfo = HiveFileInfo(dict)
                let fileHandle: OneDriveFile = OneDriveFile(fileInfo, self.authHelper)

                fileHandle.cTag = jsonData["cTag"].stringValue
                fileHandle.downloadUrl = jsonData["@microsoft.graph.downloadUrl"].stringValue
                fileHandle.name = jsonData["name"].stringValue
                fileHandle.pathName = withPath
                fileHandle.lastInfo = fileInfo
                fileHandle.drive = self

                Log.d(TAG(), "File %s on OneDrive has been created: \(withPath)");
                handleBy.didSucceed(fileHandle)
                resolver.fulfill(fileHandle)
            }.catch { error in
                Log.e(TAG(), "Creating file %s on remote OneDrive failed: \(withPath)\(HiveError.des(error as! HiveError))")
                handleBy.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    override public func fileHandle(atPath: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override public func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        return HivePromise<HiveFileHandle> { resolver in
            self.authHelper.checkExpired().then { void -> HivePromise<JSON> in
                return OneDriveAPIs.request(url: OneDriveURL(atPath).compose(),
                            method: .get, parameters: nil,
                            encoding: JSONEncoding.default,
                            headers: OneDriveHttpHeader.headers(self.authHelper),
                            avalidCode: 200, self.authHelper)
            }.done { jsonData in
                let dict: Dictionary<String, String> = [
                            HiveFileInfo.itemId: jsonData["id"].stringValue,
                            HiveFileInfo.name: jsonData["name"].stringValue,
                            HiveFileInfo.size: String(jsonData["size"].uInt64Value)]
                let fileInfo: HiveFileInfo = HiveFileInfo(dict)
                let fileHandle: OneDriveFile = OneDriveFile(fileInfo, self.authHelper)

                fileHandle.name = jsonData["name"].stringValue
                fileHandle.pathName = atPath
                fileHandle.lastInfo = fileInfo
                fileHandle.drive = self
                fileHandle.cTag = jsonData["cTag"].stringValue
                fileHandle.downloadUrl = jsonData["@microsoft.graph.downloadUrl"].stringValue
                let pathName = "/\(PathExtracter(atPath).baseNamePart())"
                let url: String = OneDriveURL(pathName, "content").compose()
                _ = CacheHelper.clearCache(self.param!.keyStorePath, url.md5)

                Log.d(TAG(), "Acquiring file %s instance succeeded: \(atPath)")
                handleBy.didSucceed(fileHandle)
                resolver.fulfill(fileHandle)
            }.catch { error in
                Log.e(TAG(), "Acquiring file %s instance failed: \(atPath)\(HiveError.des(error as! HiveError))")
                handleBy.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    public override func getItemInfo(_ path: String) -> HivePromise<HiveItemInfo> {
        return getItemInfo(path, handleBy: HiveCallback<HiveItemInfo>())
    }

    public override func getItemInfo(_ path: String, handleBy: HiveCallback<HiveItemInfo>) -> HivePromise<HiveItemInfo> {
        return HivePromise<HiveItemInfo> { resolver in
            self.authHelper.checkExpired().then { void -> HivePromise<JSON> in
                return OneDriveAPIs.request(url: OneDriveURL(path).compose(),
                            method: .get,parameters: nil,
                            encoding: JSONEncoding.default,
                            headers: OneDriveHttpHeader.headers(self.authHelper),
                            avalidCode: 200, self.authHelper)
            }.done { jsonData in
                let type: String  = jsonData["file"].stringValue != "" ? "file": "directory"
                let dict: Dictionary<String, String> = [
                            HiveItemInfo.itemId: jsonData["id"].stringValue,
                            HiveItemInfo.name: jsonData["name"].stringValue,
                            HiveItemInfo.size: String(jsonData["size"].int64Value),
                            HiveItemInfo.type: type]
                let itemInfo: HiveItemInfo = HiveItemInfo(dict)

                Log.d(TAG(), "Acquiring item info information succeeeded (info: \(itemInfo.attrDic!.description)")
                handleBy.didSucceed(itemInfo)
                resolver.fulfill(itemInfo)
            }.catch { error in
                Log.e(TAG(), "Acquiring item info information failed: \(HiveError.des(error as! HiveError))")
                handleBy.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
}
