import Foundation
import PromiseKit
import Alamofire
@inline(__always) private func TAG() -> String { return "OneDriveFile" }

@objc(OneDriveFile)
internal class OneDriveFile: HiveFileHandle {
    var name: String?
    var sessionManager = SessionManager()
    var cursor: UInt64 = 0
    var finish: Bool = false

    override init(_ info: HiveFileInfo, _ authHelper: AuthHelper) {
        super.init(info, authHelper)
    }

    override func parentPathName() -> String {
        let login = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
        guard login != "" else {
            Log.d(TAG(), "Please login first")
            return "failed"
        }
        return HelperMethods.prePath(self.pathName)
    }

    override func lastUpdatedInfo() -> HivePromise<HiveFileInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveFileInfo>) -> HivePromise<HiveFileInfo> {
        let promise = HivePromise<HiveFileInfo> { resolver in
            var url = OneDriveURL.API + "/root"
            if self.pathName != "/" {
                let ecurl = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                url  = OneDriveURL.API + "/root:\(ecurl)"
            }
            self.authHelper?.checkExpired()
                .then({ (viod) -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url,
                                 method: .get,parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(),
                                 avalidCode: 200)
                })
                .done({ (jsonData) in
                    let fileId = jsonData["id"].stringValue
                    let dic = [HiveFileInfo.itemId: fileId]
                    let fileInfo = HiveFileInfo(dic)
                    self.lastInfo = fileInfo
                    handleBy.didSucceed(fileInfo)
                    resolver.fulfill(fileInfo)
                    Log.d(TAG(), "Acquiring last file information succeeded: %s", fileInfo.description)
                })
                .catch({ (error) in
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                    Log.e(TAG(), "Acquiring last file info failed: %s", error.localizedDescription)
                })
        }
        return promise
    }

    override func moveTo(newPath: String) -> HivePromise<Bool> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool>{ resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url = (OneDriveURL.API) + (ONEDRIVE_ROOTDIR) + ":" + path
            let params: Dictionary<String, Any> = [
                "parentReference": ["path": "/drive/root:" + newPath],
                "name": self.name!,
                "@microsoft.graph.conflictBehavior": "fail"]
            self.authHelper?.checkExpired()
                .then({ (void) -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: url, method: .patch,
                                 parameters: params,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(),
                                 avalidCode: 200)
                })
                .done({ (jsonData) in
                    self.pathName = newPath + self.name!
                    resolver.fulfill(true)
                    handleBy.didSucceed(true)
                })
                .catch({ (error) in
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                    Log.e(TAG(), error.localizedDescription)
                })
        }
        return promise
    }

    override func copyTo(newPath: String) -> HivePromise<Bool> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool>{ resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var url = OneDriveURL.API + ONEDRIVE_ROOTDIR + ":" + path + ":/copy"
            if newPath == "/" {
                url = OneDriveURL.API + ONEDRIVE_ROOTDIR + "/copy"
            }
            let params: Dictionary<String, Any> = [
                "parentReference" : ["path": "/drive/root:\(newPath)"],
                "name": self.name as Any,
                "@microsoft.graph.conflictBehavior": "fail"]
            self.authHelper?.checkExpired()
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
                    resolver.fulfill(true)
                    handleBy.didSucceed(true)
                    Log.d(TAG(), "Copying this file to %s succeeded", newPath)
                })
                .catch({ (error) in
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                    Log.e(TAG(),"Copying this file to %s failed", error.localizedDescription)
                })
        }
        return promise
    }

    override func deleteItem() -> HivePromise<Bool> {
        return deleteItem(handleBy: HiveCallback<Bool>())
    }

    override func deleteItem(handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool>{ resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(ONEDRIVE_ROOTDIR):/\(path)"
            self.authHelper?.checkExpired()
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
                    self.fileId = ""
                    self.lastInfo = nil
                    resolver.fulfill(true)
                    handleBy.didSucceed(true)
                    Log.d(TAG(), "Deleting the file item succeeded")
                })
                .catch({ (error) in
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                    Log.e(TAG(), "Deleting the file item falied: %s", error.localizedDescription)
                })
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
            let url: String = "\(OneDriveURL.API)\(ONEDRIVE_ROOTDIR):\(path):/content"
            let cachePath = url.md5
            let file = HelperMethods.checkCacheFileIsExist(.ONEDRIVEACOUNT, cachePath)
            if file {
                let data: Data = HelperMethods.readCache(.ONEDRIVEACOUNT, cachePath, cursor, length)
                cursor += UInt64(data.count)
                resolver.fulfill(data)
                handleBy.didSucceed(data)
                if data.count == 0 {
                    cursor = 0
                    finish = true
                }
                return
            }
            self.authHelper?.checkExpired()
                .then({ (void) -> HivePromise<Data> in
                    return OneDriveHttpHelper.getRemoteFile(authHelper: self.authHelper!, url: url)
                })
                .done({ (jsonData) in
                    _ = HelperMethods.saveCache(.ONEDRIVEACOUNT, cachePath, data: jsonData)
                    let readData = HelperMethods.readCache(.ONEDRIVEACOUNT, cachePath, self.cursor, length)
                    self.cursor += UInt64(readData.count)
                    Log.d(TAG(), "readData succeed")
                    resolver.fulfill(readData)
                    handleBy.didSucceed(readData)
                })
                .catch({ (error) in
                    Log.e(TAG(), "readData falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                })
        }
        return promise
    }

    override func readData(_ length: Int, _ position: UInt64) -> HivePromise<Data> {
        return readData(length, position, handleBy: HiveCallback<Data>())
    }

    override func readData(_ length: Int, _ position: UInt64, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let promise = HivePromise<Data> { resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(ONEDRIVE_ROOTDIR):\(path):/content"
            let cachePath = url.md5
            let file = HelperMethods.checkCacheFileIsExist(.ONEDRIVEACOUNT, cachePath)
            if file {
                let data = HelperMethods.readCache(.ONEDRIVEACOUNT, cachePath, position, length)
                cursor += UInt64(data.count)
                resolver.fulfill(data)
                handleBy.didSucceed(data)
                return
            }
            self.authHelper?.checkExpired()
                .then({ (void) -> HivePromise<Data> in
                    return OneDriveHttpHelper.getRemoteFile(authHelper: self.authHelper!, url: url)
                })
                .done({ (jsonData) in
                    _ = HelperMethods.saveCache(.ONEDRIVEACOUNT, cachePath, data: jsonData)
                    let readData = HelperMethods.readCache(.ONEDRIVEACOUNT, cachePath, self.cursor, length)
                    self.cursor += UInt64(readData.count)
                    Log.d(TAG(), "readData succeed")
                    resolver.fulfill(readData)
                    handleBy.didSucceed(readData)
                })
                .catch({ (error) in
                    Log.e(TAG(), "readData falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                })
        }
        return promise
    }

    override func writeData(withData: Data) -> HivePromise<Int32> {
        return writeData(withData: withData, handleBy: HiveCallback<Int32>())
    }

    override func writeData(withData: Data, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let promise = HivePromise<Int32> { resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(ONEDRIVE_ROOTDIR):\(path):/content"
            let cachePath = url.md5
            let file = HelperMethods.checkCacheFileIsExist(.ONEDRIVEACOUNT, cachePath)
            if file {
                let length = HelperMethods.writeCache(.ONEDRIVEACOUNT, cachePath, data: withData, cursor)
                cursor += UInt64(length)
                resolver.fulfill(length)
                handleBy.didSucceed(length)
                return
            }
            self.authHelper?.checkExpired()
                .then({ (void) -> HivePromise<Data> in
                    return OneDriveHttpHelper.getRemoteFile(authHelper: self.authHelper!, url: url)
                })
                .done({ (jsonData) in
                    _ = HelperMethods.saveCache(.ONEDRIVEACOUNT, cachePath, data: jsonData)
                    let length = HelperMethods.writeCache(.ONEDRIVEACOUNT, cachePath, data: withData, self.cursor)
                    self.cursor += UInt64(length)
                    Log.d(TAG(), "writeData succeed")
                    resolver.fulfill(length)
                    handleBy.didSucceed(length)
                })
                .catch({ (error) in
                    Log.e(TAG(), "writeData falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                })
        }
        return promise
    }

    override func writeData(withData: Data, _ position: UInt64) -> HivePromise<Int32> {
        return writeData(withData: withData, position, handleBy: HiveCallback<Int32>())
    }

    override func writeData(withData: Data, _ position: UInt64, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let promise = HivePromise<Int32> { resolver in
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(ONEDRIVE_ROOTDIR):\(path):/content"
            let cachePath = url.md5
            let file = HelperMethods.checkCacheFileIsExist(.ONEDRIVEACOUNT, cachePath)
            if file {
                let length = HelperMethods.writeCache(.ONEDRIVEACOUNT, cachePath, data: withData, position)
                cursor += UInt64(length)
                resolver.fulfill(length)
                handleBy.didSucceed(length)
                return
            }
            self.authHelper?.checkExpired()
                .then({ (void) -> HivePromise<Data> in
                    return OneDriveHttpHelper.getRemoteFile(authHelper: self.authHelper!, url: url)
                })
                .done({ (jsonData) in
                    _ = HelperMethods.saveCache(.ONEDRIVEACOUNT, cachePath, data: jsonData)
                    let length = HelperMethods.writeCache(.ONEDRIVEACOUNT, cachePath, data: withData, self.cursor)
                    self.cursor += UInt64(length)
                    Log.d(TAG(), "writeData succeed")
                    resolver.fulfill(length)
                    handleBy.didSucceed(length)
                })
                .catch({ (error) in
                    Log.e(TAG(), "writeData falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error as! HiveError)
                })
        }
        return promise
    }

    override func commitData() -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            let accesstoken = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
            let url = self.fullUrl(self.pathName, "content")
            let headers = ["Authorization": "bearer \(accesstoken)", "Content-Type": "text/plain"]
            let data = HelperMethods.uploadFile(.ONEDRIVEACOUNT, url.md5)
            self.authHelper?.checkExpired()
                .then({ (void) -> HivePromise<HiveVoid> in
                    return OneDriveHttpHelper
                        .upload(data: data, to: url,
                                headers: headers,
                                avalidCode: 201)
                })
                .done({ (jsonData) in
                    HelperMethods.uploadCache(.ONEDRIVEACOUNT, url.md5)
                    Log.d(TAG(), "writeData succeed")
                    resolver.fulfill(true)
                })
                .catch({ (error) in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "writeData falied: %s", error.localizedDescription)
                    resolver.reject(error)
                })
        }
        return promise
    }

    override func discardData() {
        cursor = 0
        finish = false
        let url = self.fullUrl(self.pathName, "content")
        _ = HelperMethods.discardCache(.ONEDRIVEACOUNT, url.md5)
    }

    override func close() {
        cursor = 0
        finish = false
    }

    private func fullUrl(_ path: String, _ operation: String) -> String {
        if path == "" || path == "/" {
            return OneDriveURL.API + "/root/\(operation)"
        }
        let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        return OneDriveURL.API + "/root:\(ecUrl):/\(operation)"
    }
}
