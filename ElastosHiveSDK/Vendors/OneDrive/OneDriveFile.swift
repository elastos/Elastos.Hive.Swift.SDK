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
            let login = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
            guard login != "" else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                handleBy.runError(error)
                return
            }
            _ = self.authHelper!.checkExpired().done { result in
                var url = OneDriveURL.API + "/root"
                if self.pathName != "/" {
                    let ecurl = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    url  = OneDriveURL.API + "/root:\(ecurl)"
                }
                Alamofire.request(url, method: .get,
                           parameters: nil,
                             encoding: JSONEncoding.default,
                              headers: OneDriveHttpHeader.headers())
                    .responseJSON { dataResponse in
                        guard dataResponse.response?.statusCode != 401 else {
                            let error = HiveError.failue(des: TOKEN_INVALID)
                            Log.e(TAG(), "Acquiring last file info failed: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        guard dataResponse.response?.statusCode == 200 else{
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "Acquiring last file info failed: %s", error.localizedDescription)
                            handleBy.runError(error)
                            resolver.reject(error)
                            return
                        }
                        let jsonData = JSON(dataResponse.result.value as Any)
                        let fileId = jsonData["id"].stringValue
                        let dic = [HiveFileInfo.itemId: fileId]
                        let fileInfo = HiveFileInfo(dic)
                        self.lastInfo = fileInfo
                        handleBy.didSucceed(fileInfo)
                        resolver.fulfill(fileInfo)
                        Log.d(TAG(), "Acquiring last file information succeeded: %s", fileInfo.description)
                }
            }.catch { err in
                let error = HiveError.failue(des: err.localizedDescription)
                Log.e(TAG(), "Acquiring last file info failed: %s", error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            }
        }
        return promise
    }

    override func moveTo(newPath: String) -> HivePromise<Bool> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool>{ resolver in
            let login = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
            guard login != "" else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                handleBy.runError(error)
                return
            }
            _ = self.authHelper!.checkExpired().done { result in
                if self.validatePath(newPath).0 == false {
                    let error = HiveError.failue(des: self.validatePath(newPath).1)
                    resolver.reject(error)
                    handleBy.runError(error)
                    return
                }
                let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url = "\(OneDriveURL.API)\(ONEDRIVE_ROOTDIR):\(path)"
                let params: Dictionary<String, Any> = [
                    "parentReference": ["path": "/drive/root:" + newPath],
                    "name": self.name!,
                    "@microsoft.graph.conflictBehavior": "fail"]
                Alamofire.request(url, method: .patch,
                                  parameters: params,
                                  encoding: JSONEncoding.default,
                                  headers: OneDriveHttpHeader.headers())
                    .responseJSON { dataResponse in
                        guard dataResponse.response?.statusCode != 401 else {
                            let error = HiveError.failue(des: TOKEN_INVALID)
                            Log.e(TAG(), "Moving this file to %s failed.", newPath, error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        guard dataResponse.response?.statusCode == 200 else{
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "Moving this file to %s failed.", newPath, error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        self.pathName = newPath + self.name!
                        resolver.fulfill(true)
                        handleBy.didSucceed(true)
                        Log.d(TAG(), "Moving this file to %s succeeded.", newPath)
                }
            }.catch { err in
                let error = HiveError.failue(des: err.localizedDescription)
                Log.e(TAG(), "Moving this file to %s failed.", newPath, error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            }
        }
        return promise
    }

    override func copyTo(newPath: String) -> HivePromise<Bool> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool>{ resolver in
            let login = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
            guard login != "" else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                handleBy.runError(error)
                return
            }
            _ = self.authHelper!.checkExpired().done { result in
                if self.validatePath(newPath).0 == false {
                    let error = HiveError.failue(des: self.validatePath(newPath).1)
                    resolver.reject(error)
                    handleBy.runError(error)
                    return
                }
                let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                var url = OneDriveURL.API + ONEDRIVE_ROOTDIR + ":" + path + ":/copy"
                if newPath == "/" {
                    url = OneDriveURL.API + ONEDRIVE_ROOTDIR + "/copy"
                }
                let params: Dictionary<String, Any> = [
                    "parentReference" : ["path": "/drive/root:\(newPath)"],
                    "name": self.name as Any,
                    "@microsoft.graph.conflictBehavior": "fail"]
                Alamofire.request(url, method: .post,
                           parameters: params,
                             encoding: JSONEncoding.default,
                              headers: OneDriveHttpHeader.headers())
                    .responseJSON { dataResponse in
                        guard dataResponse.response?.statusCode != 401 else {
                            let error = HiveError.failue(des: TOKEN_INVALID)
                            Log.e(TAG(), "Copying this file to %s falied: %s", newPath, error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        guard dataResponse.response?.statusCode == 202 else{
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "Copying this file to %s falied: %s", newPath, error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        let urlString = dataResponse.response?.allHeaderFields["Location"] as? String ?? ""
                        self.pollingCopyresult(urlString, { result in
                            guard result == true else {
                                let error = HiveError.failue(des: "Operation failed")
                                Log.e(TAG(), "Copying this file to %s falied: %s", newPath, error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            resolver.fulfill(true)
                            handleBy.didSucceed(true)
                            Log.d(TAG(), "Copying this file to %s succeeded", newPath)
                        })
                    }
            }.catch { err in
                let error = HiveError.failue(des: err.localizedDescription)
                Log.e(TAG(), "Copying this file to %s falied: %s", newPath, error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            }
        }
        return promise
    }

    override func deleteItem() -> HivePromise<Bool> {
        return deleteItem(handleBy: HiveCallback<Bool>())
    }

    override func deleteItem(handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool>{ resolver in
            let login = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
            guard login != "" else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                handleBy.runError(error)
                return
            }
            _ = self.authHelper!.checkExpired().done { result in
                let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url: String = "\(OneDriveURL.API)\(ONEDRIVE_ROOTDIR):/\(path)"
                Alamofire.request(url, method: .delete,
                           parameters: nil,
                             encoding: JSONEncoding.default,
                              headers: OneDriveHttpHeader.headers())
                    .responseJSON(completionHandler: { dataResponse in
                        guard dataResponse.response?.statusCode != 401 else {
                            let error = HiveError.failue(des: TOKEN_INVALID)
                            Log.e(TAG(), "Deleting the file item falied: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        guard dataResponse.response?.statusCode == 204 else{

                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "Deleting the file item falied: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        self.pathName = ""
                        self.drive = nil
                        self.fileId = ""
                        self.lastInfo = nil
                        resolver.fulfill(true)
                        handleBy.didSucceed(true)
                        Log.d(TAG(), "Deleting the file item succeeded")
                    })
            }.catch { err in
                let error = HiveError.failue(des: err.localizedDescription)
                Log.e(TAG(), "Deleting the file item falied: %s", error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            }
        }
        return promise
    }

    override func readData() -> Promise<Data> {
        return readData(handleBy: HiveCallback<Data>())
    }

    override func readData(handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let promise = HivePromise<Data> { resolver in
            let login = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
            guard login != "" else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                handleBy.runError(error)
                return
            }
            if finish == true {
                Log.e(TAG(), "The file has been read finished")
                resolver.fulfill(Data())
                handleBy.didSucceed(Data())
                return
            }
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(ONEDRIVE_ROOTDIR):\(path):/content"
            let cachePath = url.md5
            let file = HelperMethods.checkCacheFileIsExist(.ONEDRIVEACOUNT, path)
            if file {
                let data: Data = HelperMethods.readCache(.ONEDRIVEACOUNT, cachePath, 0)
                cursor += UInt64(data.count)
                resolver.fulfill(data)
                handleBy.didSucceed(data)
                if data.count == 0 {
                    cursor = 0
                    finish = true
                }
                return
            }
            self.getRemoteFile(url, { (data, error) in
                guard error == nil else {
                    Log.e(TAG(), "readData falied: %s", error!.localizedDescription)
                    resolver.reject(error!)
                    handleBy.runError(error!)
                    return
                }
                let isSuccess = HelperMethods.saveCache(.ONEDRIVEACOUNT, cachePath, data: data!)
                var readData = Data()
                if isSuccess {
                    readData = HelperMethods.readCache(.ONEDRIVEACOUNT, cachePath, self.cursor)
                }
                self.cursor += UInt64(readData.count)
                Log.d(TAG(), "readData succeed")
                resolver.fulfill(readData)
                handleBy.didSucceed(readData)
            })
        }
        return promise
    }

    override func readData(_ position: UInt64) -> HivePromise<Data> {
        return readData(position, handleBy: HiveCallback<Data>())
    }

    override func readData(_ position: UInt64, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let promise = HivePromise<Data> { resolver in
            let login = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
            guard login != "" else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                handleBy.runError(error)
                return
            }
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(ONEDRIVE_ROOTDIR):\(path):/content"
            let cachePath = url.md5
            let file = HelperMethods.checkCacheFileIsExist(.ONEDRIVEACOUNT, path)
            if file {
                let stat = HelperMethods.readCache(.ONEDRIVEACOUNT, cachePath, position)
                resolver.fulfill(stat)
                handleBy.didSucceed(stat)
                return
            }
            self.getRemoteFile(url, { (data, error) in
                guard error == nil else {
                    Log.e(TAG(), "readData falied: %s", error!.localizedDescription)
                    resolver.reject(error!)
                    handleBy.runError(error!)
                    return
                }
                let isSuccess = HelperMethods.saveCache(.ONEDRIVEACOUNT, cachePath, data: data!)
                var readData = Data()
                if isSuccess {
                    readData = HelperMethods.readCache(.ONEDRIVEACOUNT, cachePath, self.cursor)
                }
                Log.d(TAG(), "readData succeed")
                resolver.fulfill(readData)
                handleBy.didSucceed(readData)
            })
        }
        return promise
    }

    override func writeData(withData: Data) -> HivePromise<Int32> {
        return writeData(withData: withData, handleBy: HiveCallback<Int32>())
    }

    override func writeData(withData: Data, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let promise = HivePromise<Int32> { resolver in
            let login = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
            guard login != "" else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                handleBy.runError(error)
                return
            }
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
            self.getRemoteFile(url, { (data, error) in
                guard error == nil else {
                    Log.e(TAG(), "writeData falied: %s", error!.localizedDescription)
                    resolver.reject(error!)
                    handleBy.runError(error!)
                    return
                }
                _ = HelperMethods.saveCache(.ONEDRIVEACOUNT, cachePath, data: data!)
                let length = HelperMethods.writeCache(.ONEDRIVEACOUNT, cachePath, data: withData, self.cursor)
                self.cursor += UInt64(length)
                Log.d(TAG(), "writeData succeed")
                resolver.fulfill(length)
                handleBy.didSucceed(length)
            })
        }
        return promise
    }

    override func writeData(withData: Data, _ position: UInt64) -> HivePromise<Int32> {
        return writeData(withData: withData, position, handleBy: HiveCallback<Int32>())
    }

    override func writeData(withData: Data, _ position: UInt64, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let promise = HivePromise<Int32> { resolver in
            let login = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
            guard login != "" else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                handleBy.runError(error)
                return
            }
            let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "\(OneDriveURL.API)\(ONEDRIVE_ROOTDIR):\(path):/content"
            let cachePath = url.md5
            let file = HelperMethods.checkCacheFileIsExist(.ONEDRIVEACOUNT, cachePath)
            if file {
                let length = HelperMethods.writeCache(.ONEDRIVEACOUNT, cachePath, data: withData, position)
                resolver.fulfill(length)
                handleBy.didSucceed(length)
                return
            }
            self.getRemoteFile(url, { (data, error) in
                guard error == nil else {
                    Log.e(TAG(), "writeData falied: %s", error!.localizedDescription)
                    resolver.reject(error!)
                    handleBy.runError(error!)
                    return
                }
                _ = HelperMethods.saveCache(.ONEDRIVEACOUNT, cachePath, data: data!)
                let length = HelperMethods.writeCache(.ONEDRIVEACOUNT, cachePath, data: withData, position)
                Log.d(TAG(), "writeData succeed")
                resolver.fulfill(length)
                handleBy.didSucceed(length)
            })
        }
        return promise
    }

    override func commitData() -> HivePromise<Bool> {
        let promise = HivePromise<Bool> { resolver in
            let login = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
            guard login != "" else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                return
            }
            _ = self.authHelper!.checkExpired().done { result in
                let accesstoken = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
                let url = self.fullUrl(self.pathName, "content")
                let headers = ["Authorization": "bearer \(accesstoken)", "Content-Type": "text/plain"]
                let data = HelperMethods.readCache(.ONEDRIVEACOUNT, url.md5, 0)
                Alamofire.upload(data, to: url,
                                 method: .put,
                                 headers: headers)
                    .responseJSON { dataResponse in
                        guard dataResponse.response?.statusCode != 401 else {
                            let error = HiveError.failue(des: TOKEN_INVALID)
                            Log.e(TAG(), "writeData falied: %s", error.localizedDescription)
                            resolver.reject(error)
                            return
                        }
                        guard dataResponse.response?.statusCode == 200 || dataResponse.response?.statusCode == 201 else{
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "writeData falied: %s", error.localizedDescription)
                            resolver.reject(error)
                            return
                        }
                        Log.d(TAG(), "writeData succeed")
                        resolver.fulfill(true)
                }
                }.catch { err in
                    let error = HiveError.failue(des: err.localizedDescription)
                    Log.e(TAG(), "writeData falied: %s", error.localizedDescription)
                    resolver.reject(error)
            }
        }
        return promise
    }

    override func discardData() {
        let login = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
        guard login != "" else {
            Log.d(TAG(), "Please login first")
            return
        }
        let url = self.fullUrl(self.pathName, "content")
        _ = HelperMethods.clearCache(.ONEDRIVEACOUNT, url.md5)
    }

    override func close() {
        let login = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
        guard login != "" else {
            Log.d(TAG(), "Please login first")
            return
        }
        cursor = 0
        finish = false
    }

    private func pollingCopyresult(_ url: String, _ copyResult: @escaping (_ isSucceed: Bool) -> Void) {
        Alamofire.request(url,
                          method: .get,
                          parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { (dataResponse) in
                let jsonData = JSON(dataResponse.result.value as Any)
                let stat = jsonData["status"].stringValue
                if stat == "completed" {
                    copyResult(true)
                    return
                }else if stat == "failed" {
                    copyResult(false)
                    return
                }else {
                    self.pollingCopyresult(url, copyResult)
                }
        }
    }

    private func pollingDowloadresult(_ url: String, _ dowloadResult: @escaping (_ isSucceed: Bool) -> Void) {
        Alamofire.request(url,
                          method: .get,
                          parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { (dataResponse) in
//                TODO
        }
    }

    private func getRemoteFile(_ url: String, _ fileResult: @escaping (_ data: Data?, _ error: HiveError?) -> Void) {
        _ = self.authHelper!.checkExpired().done { result in
            Alamofire.request(url, method: .get,
                              parameters: nil,
                              encoding: JSONEncoding.default,
                              headers: OneDriveHttpHeader.headers())
                .responseData { dataResponse in
                    let jsonStr = String(data: dataResponse.data!, encoding: .utf8) ?? ""
                    guard dataResponse.response?.statusCode != 401 else {
                        let error = HiveError.failue(des: TOKEN_INVALID)
                        fileResult(nil, error)
                        return
                    }
                    guard dataResponse.response?.statusCode == 200 else{
                        let error = HiveError.failue(des: jsonStr)
                        fileResult(nil, error)
                        return
                    }
                    let data = dataResponse.data ?? Data()
                    fileResult(data, nil)
            }
            }.catch { err in
                let error = HiveError.failue(des: err.localizedDescription)
                fileResult(nil, error)
        }
    }

    private func validatePath(_ atPath: String) -> (Bool, String) {

        if self.pathName == "/" {
            return (false, "This is root file")
        }
        return (true, "")
    }

    private func fullUrl(_ path: String, _ operation: String) -> String {
        if path == "" || path == "/" {
            return OneDriveURL.API + "/root/\(operation)"
        }
        let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        return OneDriveURL.API + "/root:\(ecUrl):/\(operation)"
    }
}
