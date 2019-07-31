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
@inline(__always) private func TAG() -> String { return "OneDriveFile" }

@objc(OneDriveFile)
internal class OneDriveFile: HiveFileHandle {
    var name: String?
    public var cTag: String?
    public var downloadUrl: String?
    var sessionManager = SessionManager()
    var cursor: UInt64 = 0
    var finish: Bool = false

    override init(_ info: HiveFileInfo, _ authHelper: AuthHelper) {
        super.init(info, authHelper)
        self.authHelper = authHelper as! OneDriveAuthHelper
    }

    override func parentPathName() -> String {
        return PathExtracter(pathName).dirNamePart()
    }

    override func lastUpdatedInfo() -> HivePromise<HiveFileInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>) -> HivePromise<HiveFileInfo> {
        let promise: HivePromise = HivePromise<HiveFileInfo> { resolver in
            var url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT)"
            if self.pathName != "/" {
                let ecurl: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                url  = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(ecurl)"
            }
            self.authHelper.checkExpired()
                .then{ viod -> HivePromise<JSON> in
                    return OneDriveAPIs
                        .request(url: url,
                                 method: .get,parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper),
                                 avalidCode: 200, self.authHelper)
                }
                .done{ jsonData in
                    let fileId: String = jsonData["id"].stringValue
                    let dic: Dictionary<String, String> = [HiveFileInfo.itemId: fileId,
                               HiveFileInfo.name: jsonData["name"].stringValue,
                               HiveFileInfo.size: String(jsonData["size"].int64Value)]
                    let fileInfo: HiveFileInfo = HiveFileInfo(dic)
                    self.lastInfo = fileInfo
                    handleBy.didSucceed(fileInfo)
                    resolver.fulfill(fileInfo)
                    Log.d(TAG(), "Acquiring last file information succeeded: \(fileInfo.description)")
                }
                .catch{ error in
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
                    Log.e(TAG(), "Acquiring last file info failed: \(HiveError.des(error as! HiveError))")
            }
        }
        return promise
    }

    override func moveTo(newPath: String) -> HivePromise<Void> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Void>())
    }

    override func moveTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void> {
        let promise: HivePromise = HivePromise<Void>{ resolver in
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path)"
            let params: Dictionary<String, Any> = [
                "parentReference": ["path": "/drive/root:\(newPath)"],
                "name": self.name!,
                "@microsoft.graph.conflictBehavior": "fail"]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveAPIs
                        .request(url: url, method: .patch,
                                 parameters: params,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper),
                                 avalidCode: 200, self.authHelper)
                }
                .done{ jsonData in
                    Log.d(TAG(), "Moving this file to \(newPath) succeeded.")
                    self.pathName = newPath + self.name!
                    handleBy.didSucceed(Void())
                    resolver.fulfill(Void())
                }
                .catch{ error in
                    Log.e(TAG(),"Moving this file to \(newPath) failed: \(HiveError.des(error as! HiveError))")
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
        let promise: HivePromise = HivePromise<Void>{ resolver in
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/copy"
            if newPath == "/" {
                url = "\(OneDriveURL.API)\(OneDriveURL.ROOT)/copy"
            }
            let params: Dictionary<String, Any> = [
                "parentReference" : ["path": "/drive/root:\(newPath)"],
                "name": self.name as Any,
                "@microsoft.graph.conflictBehavior": "fail"]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveAPIs
                        .request(url: url, method: .post,
                                 parameters: params,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper),
                                 avalidCode: statusCode.accepted.rawValue, self.authHelper)
                }
                .then{ jsonData -> HivePromise<Void> in
                    let urlString: String = jsonData["Location"].stringValue
                    return OneDriveAPIs.pollingCopyresult(urlString)
                }
                .done{ void in
                    Log.d(TAG(), "Copying this file to \(newPath) succeeded.")
                    handleBy.didSucceed(Void())
                    resolver.fulfill(Void())
                }
                .catch{ error in
                    Log.e(TAG(),"Copying this file to \(newPath) failed: \(HiveError.des(error as! HiveError))")
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
        let promise: HivePromise = HivePromise<Void>{ resolver in
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):/\(path)"
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveAPIs
                        .request(url: url, method: .delete,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper),
                                 avalidCode: statusCode.delete.rawValue, self.authHelper)
                }
                .done{ jsonData in
                    self.pathName = ""
                    self.drive = nil
                    self.fileId = ""
                    self.lastInfo = nil
                    handleBy.didSucceed(Void())
                    resolver.fulfill(Void())
                    Log.d(TAG(), "Deleting the file item succeeded")
                }
                .catch{ error in
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
                    Log.e(TAG(), "Deleting the file item falied: \(HiveError.des(error as! HiveError))")
            }
        }
        return promise
    }

    override func readData(_ length: Int) -> Promise<Data> {
        return readData(length, handleBy: HiveCallback<Data>())
    }

    override func readData(_ length: Int, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let promise: HivePromise = HivePromise<Data> { resolver in
            if finish == true {
                Log.e(TAG(), "The file has been read finished")
                handleBy.didSucceed(Data())
                resolver.fulfill(Data())
                return
            }
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/content"
            let cacheName: String = url.md5
            let file: Bool = CacheHelper.checkCacheFileIsExist((drive as! OneDriveDrive).param!.keyStorePath, cacheName)
            if file {
                let data: Data = CacheHelper.readCache((drive as! OneDriveDrive).param!.keyStorePath, cacheName, cursor, length)
                cursor += UInt64(data.count)
                handleBy.didSucceed(data)
                resolver.fulfill(data)
                if data.count == 0 {
                    cursor = 0
                    finish = true
                }
                return
            }
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<Data> in
                    return OneDriveAPIs.getRemoteFile(authHelper: self.authHelper, url: url)
                }
                .done{ jsonData in
                    _ = CacheHelper.saveCache((self.drive as! OneDriveDrive).param!.keyStorePath, cacheName, data: jsonData)
                    let readData: Data = CacheHelper.readCache((self.drive as! OneDriveDrive).param!.keyStorePath, cacheName, self.cursor, length)
                    self.cursor += UInt64(readData.count)
                    Log.d(TAG(), "readData succeed")
                    handleBy.didSucceed(readData)
                    resolver.fulfill(readData)
                }
                .catch{ error in
                    Log.e(TAG(), "readData falied: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func readData(_ length: Int, _ position: UInt64) -> HivePromise<Data> {
        return readData(length, position, handleBy: HiveCallback<Data>())
    }

    override func readData(_ length: Int, _ position: UInt64, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let promise: HivePromise = HivePromise<Data> { resolver in
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/content"
            let cacheName: String = url.md5
            let file: Bool = CacheHelper.checkCacheFileIsExist((drive as! OneDriveDrive).param!.keyStorePath, cacheName)
            if file {
                let data: Data = CacheHelper.readCache((drive as! OneDriveDrive).param!.keyStorePath, cacheName, position, length)
                cursor += UInt64(data.count)
                resolver.fulfill(data)
                handleBy.didSucceed(data)
                return
            }
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<Data> in
                    return OneDriveAPIs.getRemoteFile(authHelper: self.authHelper, url: url)
                }
                .done{ jsonData in
                    _ = CacheHelper.saveCache((self.drive as! OneDriveDrive).param!.keyStorePath, cacheName, data: jsonData)
                    let readData: Data = CacheHelper.readCache((self.drive as! OneDriveDrive).param!.keyStorePath, cacheName, self.cursor, length)
                    self.cursor += UInt64(readData.count)
                    Log.d(TAG(), "readData succeed")
                    handleBy.didSucceed(readData)
                    resolver.fulfill(readData)
                }
                .catch{ error in
                    Log.e(TAG(), "readData falied: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func writeData(withData: Data) -> HivePromise<Int32> {
        return writeData(withData: withData, handleBy: HiveCallback<Int32>())
    }

    override func writeData(withData: Data, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let promise: HivePromise = HivePromise<Int32> { resolver in
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/content"
            let cacheName: String = url.md5
            let file: Bool = CacheHelper.checkCacheFileIsExist((drive as! OneDriveDrive).param!.keyStorePath, cacheName)
            if file {
                let length: Int32 = CacheHelper.writeCache((drive as! OneDriveDrive).param!.keyStorePath, cacheName, data: withData, 0, true)
                cursor += UInt64(length)
                handleBy.didSucceed(length)
                resolver.fulfill(length)
                return
            }
            self.authHelper.checkExpired()
                .then{ (void) -> HivePromise<Data> in
                    return OneDriveAPIs.getRemoteFile(authHelper: self.authHelper, url: url)
                }
                .done{ jsonData in
                    _ = CacheHelper.saveCache((self.drive as! OneDriveDrive).param!.keyStorePath, cacheName, data: jsonData)
                    let length: Int32 = CacheHelper.writeCache((self.drive as! OneDriveDrive).param!.keyStorePath, cacheName, data: withData, 0, true)
                    Log.d(TAG(), "writeData succeed")
                    handleBy.didSucceed(length)
                    resolver.fulfill(length)
                }
                .catch{ error in
                    Log.e(TAG(), "writeData falied: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func writeData(withData: Data, _ position: UInt64) -> HivePromise<Int32> {
        return writeData(withData: withData, position, handleBy: HiveCallback<Int32>())
    }

    override func writeData(withData: Data, _ position: UInt64, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let promise: HivePromise = HivePromise<Int32> { resolver in
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/content"
            let cachePath: String = url.md5
            let file: Bool = CacheHelper.checkCacheFileIsExist((drive as! OneDriveDrive).param!.keyStorePath, cachePath)
            if file {
                let length: Int32 = CacheHelper.writeCache((drive as! OneDriveDrive).param!.keyStorePath, cachePath, data: withData, position, false)
                handleBy.didSucceed(length)
                resolver.fulfill(length)
                return
            }
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<Data> in
                    return OneDriveAPIs.getRemoteFile(authHelper: self.authHelper, url: url)
                }
                .done{ jsonData in
                    _ = CacheHelper.saveCache((self.drive as! OneDriveDrive).param!.keyStorePath, cachePath, data: jsonData)
                    let length: Int32 = CacheHelper.writeCache((self.drive as! OneDriveDrive).param!.keyStorePath, cachePath, data: withData, self.cursor, false)
                    Log.d(TAG(), "writeData succeed")
                    handleBy.didSucceed(length)
                    resolver.fulfill(length)
                }
                .catch{ error in
                    Log.e(TAG(), "writeData falied: \(HiveError.des(error as! HiveError))")
                    handleBy.runError(error as! HiveError)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func commitData() -> HivePromise<Void> {
        let promise: HivePromise = HivePromise<Void> { resolver in
            let accesstoken: String = (self.authHelper as! OneDriveAuthHelper).token?.accessToken ?? ""
            let path: String = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/createUploadSession"
            let params: Dictionary<String, Any> = ["file": "file",                                                      "@microsoft.graph.conflictBehavior": "fail"]
            let headers: Dictionary<String, String> = [
                OneDriveHttpHeader.ContentType: "application/json;charset=UTF-8",
                OneDriveHttpHeader.Authorization: "bearer \(accesstoken)",
                "if-match": self.cTag!]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<String> in
                    return OneDriveAPIs
                        .createUploadSession(url: url,
                                             method: .post,
                                             parameters: params,
                                             encoding: JSONEncoding.default,
                                             headers: headers,
                                             self.authHelper)
                }.then{ uploadUrl -> HivePromise<Void> in
                    let cacheUrl: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/content"
                    let data: Data = CacheHelper.uploadFile((self.drive as! OneDriveDrive).param!.keyStorePath, cacheUrl.md5)
                    let length: Int64 = Int64(data.count)
                    var end: Int64 = length - 1
                    if length == 0 {
                        end = length
                    }
                    let headers: Dictionary<String, String> = [
                        "Content-Type": "application/json;charset=UTF-8",
                        "Authorization": "bearer \(accesstoken)",
                        "Content-Length": "\(length)",
                        "Content-Range": "bytes 0-\(end)/\(length)"]
                    return OneDriveAPIs
                        .uploadWriteData(data: data,
                                         to: uploadUrl,
                                         method: .put,
                                         headers: headers,
                                         self.authHelper)
                }
                .done{ jsonData in
                    self.cursor = 0
                    self.finish = false
                    Log.d(TAG(), "writeData succeed")
                    resolver.fulfill(Void())
                }
                .catch{ error in
                    Log.e(TAG(), "writeData falied: \(HiveError.des(error as! HiveError))")
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func discardData() {
        cursor = 0
        finish = false
        let url = OneDriveURL(pathName, "content").compose()
        _ = CacheHelper.clearCache((drive as! OneDriveDrive).param!.keyStorePath, url.md5)
    }

}
