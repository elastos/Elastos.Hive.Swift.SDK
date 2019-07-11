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
        let promise = HivePromise<HiveFileInfo> { resolver in
            var url = OneDriveURL.API + OneDriveURL.ROOT
            if self.pathName != "/" {
                let ecurl = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                url  = OneDriveURL.API + "\(OneDriveURL.ROOT):\(ecurl)"
            }
            self.authHelper.checkExpired()
                .then{ viod -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url,
                                 method: .get,parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper),
                                 avalidCode: 200, self.authHelper)
                }
                .done{ jsonData in
                    let fileId = jsonData["id"].stringValue
                    let dic = [HiveFileInfo.itemId: fileId,
                               HiveFileInfo.name: jsonData["name"].stringValue,
                               HiveFileInfo.size: String(jsonData["size"].int64Value)]
                    let fileInfo = HiveFileInfo(dic)
                    self.lastInfo = fileInfo
                    handleBy.didSucceed(fileInfo)
                    resolver.fulfill(fileInfo)
                    Log.d(TAG(), "Acquiring last file information succeeded: " + fileInfo.description)
                }
                .catch{ error in
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                    Log.e(TAG(), "Acquiring last file info failed: " + HiveError.des(error as! HiveError))
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
            let url = (OneDriveURL.API) + (OneDriveURL.ROOT) + ":" + path
            let params: Dictionary<String, Any> = [
                "parentReference": ["path": "/drive/root:" + newPath],
                "name": self.name!,
                "@microsoft.graph.conflictBehavior": "fail"]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .patch,
                                 parameters: params,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper),
                                 avalidCode: 200, self.authHelper)
                }
                .done{ jsonData in
                    self.pathName = newPath + self.name!
                    resolver.fulfill(HiveVoid())
                    handleBy.didSucceed(HiveVoid())
                }
                .catch{ error in
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                    Log.e(TAG(), HiveError.des(error as! HiveError))
            }
        }
        return promise
    }

    override func copyTo(newPath: String) -> HivePromise<HiveVoid> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<HiveVoid>())
    }

    override func copyTo(newPath: String, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid>{ resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var url = OneDriveURL.API + OneDriveURL.ROOT + ":" + path + ":/copy"
            if newPath == "/" {
                url = OneDriveURL.API + OneDriveURL.ROOT + "/copy"
            }
            let params: Dictionary<String, Any> = [
                "parentReference" : ["path": "/drive/root:\(newPath)"],
                "name": self.name as Any,
                "@microsoft.graph.conflictBehavior": "fail"]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .post,
                                 parameters: params,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper),
                                 avalidCode: statusCode.accepted.rawValue, self.authHelper)
                }
                .then{ jsonData -> HivePromise<HiveVoid> in
                    let urlString = jsonData["Location"].stringValue
                    return OneDriveHttpHelper.pollingCopyresult(urlString)
                }
                .done{ void in
                    resolver.fulfill(HiveVoid())
                    handleBy.didSucceed(HiveVoid())
                    Log.d(TAG(), "Copying this file to %s succeeded", newPath)
                }
                .catch{ error in
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                    Log.e(TAG(),"Copying this file to %s failed", HiveError.des(error as! HiveError))
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
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return OneDriveHttpHelper
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
                    resolver.fulfill(HiveVoid())
                    handleBy.didSucceed(HiveVoid())
                    Log.d(TAG(), "Deleting the file item succeeded")
                }
                .catch{ error in
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                    Log.e(TAG(), "Deleting the file item falied: " + HiveError.des(error as! HiveError))
            }
        }
        return promise
    }

    override func readData(_ length: Int) -> Promise<Data> {
        return readData(length, handleBy: HiveCallback<Data>())
    }

    override func readData(_ length: Int, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let promise = HivePromise<Data> { resolver in
            if finish == true {
                Log.e(TAG(), "The file has been read finished")
                resolver.fulfill(Data())
                handleBy.didSucceed(Data())
                return
            }
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/content"
            let cachePath = url.md5
            let file = CacheHelper.checkCacheFileIsExist(.oneDrive, cachePath)
            if file {
                let data: Data = CacheHelper.readCache(.oneDrive, cachePath, cursor, length)
                cursor += UInt64(data.count)
                resolver.fulfill(data)
                handleBy.didSucceed(data)
                if data.count == 0 {
                    cursor = 0
                    finish = true
                }
                return
            }
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<Data> in
                    return OneDriveHttpHelper.getRemoteFile(authHelper: self.authHelper, url: url)
                }
                .done{ jsonData in
                    _ = CacheHelper.saveCache(.oneDrive, cachePath, data: jsonData)
                    let readData = CacheHelper.readCache(.oneDrive, cachePath, self.cursor, length)
                    self.cursor += UInt64(readData.count)
                    Log.d(TAG(), "readData succeed")
                    resolver.fulfill(readData)
                    handleBy.didSucceed(readData)
                }
                .catch{ error in
                    Log.e(TAG(), "readData falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }

    override func readData(_ length: Int, _ position: UInt64) -> HivePromise<Data> {
        return readData(length, position, handleBy: HiveCallback<Data>())
    }

    override func readData(_ length: Int, _ position: UInt64, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let promise = HivePromise<Data> { resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/content"
            let cachePath = url.md5
            let file = CacheHelper.checkCacheFileIsExist(.oneDrive, cachePath)
            if file {
                let data = CacheHelper.readCache(.oneDrive, cachePath, position, length)
                cursor += UInt64(data.count)
                resolver.fulfill(data)
                handleBy.didSucceed(data)
                return
            }
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<Data> in
                    return OneDriveHttpHelper.getRemoteFile(authHelper: self.authHelper, url: url)
                }
                .done{ jsonData in
                    _ = CacheHelper.saveCache(.oneDrive, cachePath, data: jsonData)
                    let readData = CacheHelper.readCache(.oneDrive, cachePath, self.cursor, length)
                    self.cursor += UInt64(readData.count)
                    Log.d(TAG(), "readData succeed")
                    resolver.fulfill(readData)
                    handleBy.didSucceed(readData)
                }
                .catch{ error in
                    Log.e(TAG(), "readData falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }

    override func writeData(withData: Data) -> HivePromise<Int32> {
        return writeData(withData: withData, handleBy: HiveCallback<Int32>())
    }

    override func writeData(withData: Data, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let promise = HivePromise<Int32> { resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/content"
            let cachePath = url.md5
            let file = CacheHelper.checkCacheFileIsExist(.oneDrive, cachePath)
            if file {
                let length = CacheHelper.writeCache(.oneDrive, cachePath, data: withData, 0, true)
                cursor += UInt64(length)
                resolver.fulfill(length)
                handleBy.didSucceed(length)
                return
            }
            self.authHelper.checkExpired()
                .then{ (void) -> HivePromise<Data> in
                    return OneDriveHttpHelper.getRemoteFile(authHelper: self.authHelper, url: url)
                }
                .done{ jsonData in
                    _ = CacheHelper.saveCache(.oneDrive, cachePath, data: jsonData)
                    let length = CacheHelper.writeCache(.oneDrive, cachePath, data: withData, 0, true)
                    Log.d(TAG(), "writeData succeed")
                    resolver.fulfill(length)
                    handleBy.didSucceed(length)
                }
                .catch{ error in
                    Log.e(TAG(), "writeData falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }

    override func writeData(withData: Data, _ position: UInt64) -> HivePromise<Int32> {
        return writeData(withData: withData, position, handleBy: HiveCallback<Int32>())
    }

    override func writeData(withData: Data, _ position: UInt64, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let promise = HivePromise<Int32> { resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/content"
            let cachePath = url.md5
            let file = CacheHelper.checkCacheFileIsExist(.oneDrive, cachePath)
            if file {
                let length = CacheHelper.writeCache(.oneDrive, cachePath, data: withData, position, false)
                resolver.fulfill(length)
                handleBy.didSucceed(length)
                return
            }
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<Data> in
                    return OneDriveHttpHelper.getRemoteFile(authHelper: self.authHelper, url: url)
                }
                .done{ jsonData in
                    _ = CacheHelper.saveCache(.oneDrive, cachePath, data: jsonData)
                    let length = CacheHelper.writeCache(.oneDrive, cachePath, data: withData, self.cursor, false)
                    Log.d(TAG(), "writeData succeed")
                    resolver.fulfill(length)
                    handleBy.didSucceed(length)
                }
                .catch{ error in
                    Log.e(TAG(), "writeData falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
            }
        }
        return promise
    }

    override func commitData() -> HivePromise<HiveVoid> {
        let promise = HivePromise<HiveVoid> { resolver in
            let accesstoken = (self.authHelper as! OneDriveAuthHelper).token?.accessToken ?? ""
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/createUploadSession"
            let params: Dictionary<String, Any> = ["file": "file",                                                      "@microsoft.graph.conflictBehavior": "fail"]
            let headers = [
                OneDriveHttpHeader.ContentType: "application/json;charset=UTF-8",
                OneDriveHttpHeader.Authorization: "bearer \(accesstoken)",
                "if-match": self.cTag!]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<String> in
                    return OneDriveHttpHelper
                        .createUploadSession(url: url,
                                             method: .post,
                                             parameters: params,
                                             encoding: JSONEncoding.default,
                                             headers: headers,
                                             self.authHelper)
                }.then{ uploadUrl -> HivePromise<HiveVoid> in
                    let cacheUrl: String = "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/content"
                    let data = CacheHelper.uploadFile(.oneDrive, cacheUrl.md5)
                    let length = Int64(data.count)
                    var end = length - 1
                    if length == 0 {
                        end = length
                    }
                    let headers: Dictionary<String, String> = [
                        "Content-Type": "application/json;charset=UTF-8",
                        "Authorization": "bearer \(accesstoken)",
                        "Content-Length": "\(length)",
                        "Content-Range": "bytes 0-\(end)/\(length)"]
                    return OneDriveHttpHelper
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
                    resolver.fulfill(HiveVoid())
                }
                .catch{ error in
                    Log.e(TAG(), "writeData falied: " + HiveError.des(error as! HiveError))
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func discardData() {
        cursor = 0
        finish = false
        let url = OneDriveURL(pathName, "content").compose()
        _ = CacheHelper.clearCache(.oneDrive, url.md5)
    }

    override func close() {
        self.discardData()
    }
}
