import Foundation
import Alamofire
import PromiseKit

@inline(__always) private func TAG() -> String { return "OneDriveDrive" }

public class OneDriveDrive: HiveDriveHandle {
    private var authHelper: OneDriveAuthHelper
    internal static var oneDriveInstance: HiveDriveHandle?

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
        let promise = HivePromise<HiveDriveInfo> { resolver in
            self.authHelper.checkExpired()
                .then { void -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: OneDriveURL.API + "/root",
                                 method: .get,parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper),
                                 avalidCode: 200, self.authHelper)
                }
                .done { jsonData in
                    let driId = jsonData["id"].stringValue
                    let dic = [HiveDriveInfo.driveId: driId]
                    let driveInfo = HiveDriveInfo(dic)
                    self.lastInfo = driveInfo
                    handleBy.didSucceed(driveInfo)
                    resolver.fulfill(driveInfo)
                    Log.d(TAG(), "Acquiring last drive information succeeeded (info: %s)", driveInfo.attrDic!.description)
                }
                .catch { error in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "Acquireing last drve information falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
            }
        }
        return promise
    }

    override public func rootDirectoryHandle() -> HivePromise<HiveDirectoryHandle> {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override public func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                self.authHelper.checkExpired()
                    .then { void -> HivePromise<JSON> in
                        return OneDriveHttpHelper
                            .request(url: OneDriveURL.API + "/root",
                                     method: .get,parameters: nil,
                                     encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers(self.authHelper),
                                     avalidCode: 200, self.authHelper)
                    }
                    .done { jsonData in
                        let dirId = jsonData["id"].stringValue
                        let dic = [HiveDirectoryInfo.itemId: dirId]
                        let dirInfo = HiveDirectoryInfo(dic)
                        let dirHandle = OneDriveDirectory(dirInfo, self.authHelper)

                        dirHandle.name = jsonData["id"].stringValue
                        dirHandle.pathName = "/"
                        dirHandle.drive = self
                        dirHandle.lastInfo = dirInfo
                        handleBy.didSucceed(dirHandle)
                        resolver.fulfill(dirHandle)
                        Log.d(TAG(), "Acquiring root directory instance success")
                    }
                    .catch { error in
                        let error = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "Acquiring root directory instance falied: %s", error.localizedDescription)
                        resolver.reject(error)
                        handleBy.runError(error)
                }
            }
            return promise
    }

    override public func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override public func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                let params: Dictionary<String, Any> = [
                    "name": PathExtracter(withPath).baseNamePart() as Any,
                    "folder": [: ],
                    "@microsoft.graph.conflictBehavior": "fail"]
                let path = PathExtracter(withPath).dirNamePart()
                let url = OneDriveURL(path, "children").compose()
                self.authHelper.checkExpired()
                    .then { void -> HivePromise<JSON> in
                        return OneDriveHttpHelper
                            .request(url: url,
                                     method: .post,
                                     parameters: params,
                                     encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers(self.authHelper),
                                     avalidCode: statusCode.created.rawValue, self.authHelper)
                    }
                    .done { jsonData in
                        let dirId = jsonData["id"].stringValue
                        let dic = [HiveDirectoryInfo.itemId: dirId]
                        let dirInfo = HiveDirectoryInfo(dic)
                        let dirHandle = OneDriveDirectory(dirInfo, self.authHelper)
                        dirHandle.name = jsonData["name"].string
                        dirHandle.pathName = withPath
                        dirHandle.drive = self
                        dirHandle.lastInfo = dirInfo
                        handleBy.didSucceed(dirHandle)
                        resolver.fulfill(dirHandle)
                        Log.d(TAG(), "Directory %s has been created successfully", withPath)
                    }
                    .catch{ error in
                        let error = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "createDirectory falied: %s", error.localizedDescription)
                        resolver.reject(error)
                        handleBy.runError(error)
                }
            }
            return promise
    }

    override public func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override public func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                self.authHelper.checkExpired()
                    .then { void -> HivePromise<JSON> in
                        return OneDriveHttpHelper
                            .request(url: OneDriveURL(atPath).compose(),
                                     method: .get, parameters: nil,
                                     encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers(self.authHelper),
                                     avalidCode: 200, self.authHelper)
                    }
                    .done { jsonData in
                        let dirId = jsonData["id"].stringValue
                        let dic = [HiveDirectoryInfo.itemId: dirId]
                        let dirInfo = HiveDirectoryInfo(dic)
                        let dirHandle = OneDriveDirectory(dirInfo, self.authHelper)
                        dirHandle.name = jsonData["name"].stringValue
                        dirHandle.pathName = atPath
                        dirHandle.drive = self
                        dirHandle.lastInfo = dirInfo
                        handleBy.didSucceed(dirHandle)
                        resolver.fulfill(dirHandle)
                        Log.d(TAG(), "Acquiring directory %s instance succeeded", atPath)
                    }
                    .catch { error in
                        let error = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "Acquiring directory %s instance failed", atPath, error.localizedDescription)
                        resolver.reject(error)
                        handleBy.runError(error)
                }
            }
            return promise
    }

    override public func createFile(withPath: String) -> HivePromise<HiveFileHandle> {
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override public func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle> {
            let promise = HivePromise<HiveFileHandle> { resolver in
                self.authHelper.checkExpired()
                    .then { void -> HivePromise<JSON> in
                        return OneDriveHttpHelper
                            .request(url: OneDriveURL(withPath, "content").compose(),
                                     method: .put, parameters: nil,
                                     encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers(self.authHelper),
                                     avalidCode: statusCode.created.rawValue, self.authHelper)
                    }
                    .done { jsonData in
                        let fileId = jsonData["id"].stringValue
                        let dic = [HiveFileInfo.itemId: fileId]
                        let fileInfo = HiveFileInfo(dic)
                        let fileHandle = OneDriveFile(fileInfo, self.authHelper)
                        fileHandle.name = jsonData["name"].stringValue
                        fileHandle.pathName = withPath
                        fileHandle.lastInfo = fileInfo
                        fileHandle.drive = self
                        handleBy.didSucceed(fileHandle)
                        resolver.fulfill(fileHandle)
                        Log.d(TAG(), "File %s on OneDrive has been created.", withPath);
                    }
                    .catch { error in
                        let error = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "Creating file %s on remote OneDrive failed %s", withPath, error.localizedDescription)
                        resolver.reject(error)
                        handleBy.runError(error)
                }
            }
            return promise
    }

    override public func fileHandle(atPath: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override public func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle> {
            let promise = HivePromise<HiveFileHandle> { resolver in
                self.authHelper.checkExpired()
                    .then { void -> HivePromise<JSON> in
                        return OneDriveHttpHelper
                            .request(url: OneDriveURL(atPath).compose(),
                                     method: .get, parameters: nil,
                                     encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers(self.authHelper),
                                     avalidCode: 200, self.authHelper)
                    }
                    .done { jsonData in
                        let fileId = jsonData["id"].stringValue
                        let dic = [HiveFileInfo.itemId: fileId]
                        let fileInfo = HiveFileInfo(dic)
                        let fileHandle = OneDriveFile(fileInfo, self.authHelper)
                        fileHandle.name = jsonData["name"].stringValue
                        fileHandle.pathName = atPath
                        fileHandle.lastInfo = fileInfo
                        fileHandle.drive = self
                        handleBy.didSucceed(fileHandle)
                        resolver.fulfill(fileHandle)
                        let pathName = ("/" + PathExtracter(atPath).baseNamePart())
                        let url = OneDriveURL(pathName, "content").compose()
                        _ = CacheHelper.clearCache(.oneDrive, url.md5)
                        Log.d(TAG(), "Acquiring file %s instance succeeded", atPath)
                    }
                    .catch { error in
                        let error = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "Acquiring file %s instance failed: %s", atPath, error.localizedDescription)
                        resolver.reject(error)
                        handleBy.runError(error)
                }
            }
            return promise
    }

    public override func getItemInfo(_ path: String) -> HivePromise<HiveItemInfo> {
        return getItemInfo(path, handleBy: HiveCallback<HiveItemInfo>())
    }

    public override func getItemInfo(_ path: String, handleBy: HiveCallback<HiveItemInfo>) -> HivePromise<HiveItemInfo> {
        let promise = HivePromise<HiveItemInfo> { resolver in
            self.authHelper.checkExpired()
                .then { void -> HivePromise<JSON> in
                    return OneDriveHttpHelper
                        .request(url: OneDriveURL(path).compose(),
                                 method: .get,parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: OneDriveHttpHeader.headers(self.authHelper),
                                 avalidCode: 200, self.authHelper)
                }
                .done { jsonData in
                    let file = jsonData["file"].stringValue
                    var type: String = "directory"
                    if file != "" {
                        type = "file"
                    }
                    let dic = [HiveItemInfo.itemId: jsonData["id"].stringValue,
                               HiveItemInfo.name: jsonData["name"].stringValue,
                               HiveItemInfo.size: jsonData["size"].stringValue,
                               HiveItemInfo.type: type]
                    let itemInfo = HiveItemInfo(dic)
                    resolver.fulfill(itemInfo)
                    handleBy.didSucceed(itemInfo)
                    Log.d(TAG(), "Acquiring item info information succeeeded (info: %s)", itemInfo.attrDic!.description)
                }
                .catch { error in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "Acquireing item info information falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
            }
        }
        return promise
    }
}
