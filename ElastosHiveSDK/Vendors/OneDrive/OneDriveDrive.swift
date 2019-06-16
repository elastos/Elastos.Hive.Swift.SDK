import Foundation
import Alamofire
import PromiseKit

@inline(__always) private func TAG() -> String { return "OneDriveDrive" }

public class OneDriveDrive: HiveDriveHandle {
    private var authHelper: AuthHelper
    internal static var oneDriveInstance: HiveDriveHandle?

    init(_ info: HiveDriveInfo, _ authHelper: AuthHelper) {
        self.authHelper = authHelper
        super.init(DriveType.oneDrive, info)
    }

    static func createInstance(_ info: HiveDriveInfo, _ authHelper: AuthHelper) {
        if oneDriveInstance == nil {
            let client = OneDriveDrive(info, authHelper)
            oneDriveInstance = client
        }
    }

    static func sharedInstance() -> OneDriveDrive {
        return oneDriveInstance as! OneDriveDrive
    }

    override public func lastUpdatedInfo() -> HivePromise<HiveDriveInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>())
    }

    override public func lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>) -> HivePromise<HiveDriveInfo> {
        let promise = HivePromise<HiveDriveInfo> { resolver in
            _ = self.authHelper.checkExpired().done { result in
                Alamofire.request(OneDriveURL.API + "/root", method: .get,
                                  parameters: nil,
                                    encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers())
                    .responseJSON { dataResponse in
                        guard dataResponse.response?.statusCode != 401 else {
                            let error = HiveError.failue(des: TOKEN_INVALID)
                            Log.e(TAG(), "Acquire last drive information failed: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        guard dataResponse.response?.statusCode == 200 else{
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            handleBy.runError(error)
                            resolver.reject(error)
                            return
                        }
                        let jsonData = JSON(dataResponse.result.value as Any)
                        let driId = jsonData["id"].stringValue
                        let driveInfo = HiveDriveInfo(driId)
                        driveInfo.installValue(jsonData)
                        self.lastInfo = driveInfo
                        handleBy.didSucceed(driveInfo)
                        resolver.fulfill(driveInfo)
                        Log.d(TAG(), "Acquiring last drive information succeeeded (info: %s)", driveInfo.ddescription)
                }
            }.catch { err in
                let error = HiveError.failue(des: err.localizedDescription)
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
                _ = self.authHelper.checkExpired().done { result in
                    Alamofire.request(OneDriveURL.API + "/root", method: .get,
                                      parameters: nil,
                                        encoding: JSONEncoding.default,
                                         headers: OneDriveHttpHeader.headers())
                        .responseJSON { dataResponse in
                            guard dataResponse.response?.statusCode != 401 else {
                                let error = HiveError.failue(des: TOKEN_INVALID)
                                Log.e(TAG(), "Acquiring root directory instance failed: %s", error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            guard dataResponse.response?.statusCode == 200 else{
                                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                                Log.e(TAG(), "Acquiring root directory instance failed: %s", error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            let jsonData = JSON(dataResponse.result.value as Any)
                            let dirId = jsonData["id"].stringValue
                            let dirInfo = HiveDirectoryInfo(dirId)
                            dirInfo.installValue(jsonData)
                            let dirHandle = OneDriveDirectory(dirInfo, self.authHelper)
                            dirHandle.name = jsonData["id"].stringValue
                            dirHandle.pathName = "/"
                            dirHandle.drive = self
                            dirHandle.lastInfo = dirInfo
                            handleBy.didSucceed(dirHandle)
                            resolver.fulfill(dirHandle)
                            Log.d(TAG(), "Acquiring root directory instance success")
                    }
                }.catch { err in
                    let error = HiveError.failue(des: err.localizedDescription)
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
                _ = self.authHelper.checkExpired().done { result in
                    let params: Dictionary<String, Any> = [
                        "name": HelperMethods.endPath(withPath) as Any,
                        "folder": [: ],
                        "@microsoft.graph.conflictBehavior": "fail"]
                    let path = HelperMethods.prePath(withPath)
                    let url = self.fullUrl(path, "children")
                    Alamofire.request(url,
                                      method: .post,
                                      parameters: params,
                                      encoding: JSONEncoding.default,
                                      headers: OneDriveHttpHeader.headers())
                        .responseJSON { dataResponse in
                            guard dataResponse.response?.statusCode != 401 else {
                                let error = HiveError.failue(des: TOKEN_INVALID)
                                Log.e(TAG(), "Creating directory %s failed", withPath, error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            guard dataResponse.response?.statusCode == 201 else{
                                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                                Log.e(TAG(), "Creating directory %s failed", withPath, error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            let jsonData = JSON(dataResponse.result.value as Any)
                            let dirId = jsonData["id"].stringValue
                            let dirInfo = HiveDirectoryInfo(dirId)
                            dirInfo.installValue(jsonData)
                            let dirHandle = OneDriveDirectory(dirInfo, self.authHelper)
                            dirHandle.name = jsonData["name"].string
                            dirHandle.pathName = withPath
                            dirHandle.drive = self
                            dirHandle.lastInfo = dirInfo
                            handleBy.didSucceed(dirHandle)
                            resolver.fulfill(dirHandle)
                            Log.d(TAG(), "Directory %s has been created successfully", withPath)
                    }
                }.catch { err in
                    let error = HiveError.failue(des: err.localizedDescription)
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
                _ = self.authHelper.checkExpired().done { result in
                    Alamofire.request(self.fullUrl("/\(atPath)"), method: .get,
                                      parameters: nil,
                                        encoding: JSONEncoding.default,
                                         headers: OneDriveHttpHeader.headers())
                        .responseJSON { dataResponse in
                            guard dataResponse.response?.statusCode != 401 else {
                                let error = HiveError.failue(des: TOKEN_INVALID)
                                Log.e(TAG(), "Acquire directory %s instance failed: %s", atPath, error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            guard dataResponse.response?.statusCode == 200 else{
                                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                                Log.e(TAG(), "Acquire directory %s instance failed: %s", atPath, error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            let jsonData = JSON(dataResponse.result.value as Any)
                            let dirId = jsonData["id"].stringValue
                            let dirInfo = HiveDirectoryInfo(dirId)
                            dirInfo.installValue(jsonData)
                            let dirHandle = OneDriveDirectory(dirInfo, self.authHelper)
                            dirHandle.name = jsonData["name"].stringValue
                            dirHandle.pathName = atPath
                            dirHandle.drive = self
                            dirHandle.lastInfo = dirInfo
                            handleBy.didSucceed(dirHandle)
                            resolver.fulfill(dirHandle)
                            Log.d(TAG(), "Acquiring directory %s instance succeeded", atPath)
                    }
                }.catch { err in
                    let error = HiveError.failue(des: err.localizedDescription)
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
                _ = self.authHelper.checkExpired().done { result in
                    Alamofire.request(self.fullUrl(withPath, "content"), method: .put,
                                  parameters: nil,
                                    encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers())
                        .responseJSON { dataResponse in
                            guard dataResponse.response?.statusCode != 401 else {
                                let error = HiveError.failue(des: TOKEN_INVALID)
                                Log.e(TAG(), "Creating file %s on remote OneDrive failed %s", withPath, error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            guard dataResponse.response?.statusCode == 200 || dataResponse.response?.statusCode == 201 else{
                                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                                Log.e(TAG(), "Creating file %s on remote OneDrive failed %s", withPath, error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            let jsonData = JSON(dataResponse.result.value as Any)
                            let fileId = jsonData["id"].stringValue
                            let fileInfo = HiveFileInfo(fileId)
                            fileInfo.installValue(jsonData)
                            let fileHandle = OneDriveFile(fileInfo, self.authHelper)
                            fileHandle.name = jsonData["name"].stringValue
                            fileHandle.pathName = withPath
                            fileHandle.lastInfo = fileInfo
                            fileHandle.drive = self
                            handleBy.didSucceed(fileHandle)
                            resolver.fulfill(fileHandle)
                            Log.d(TAG(), "File %s on OneDrive has been created.", withPath);
                    }
                }.catch { err in
                    let error = HiveError.failue(des: err.localizedDescription)
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
                _ = self.authHelper.checkExpired().done { result in
                    Alamofire.request(self.fullUrl(atPath), method: .get,
                                      parameters: nil,
                                        encoding: JSONEncoding.default,
                                         headers: OneDriveHttpHeader.headers())
                        .responseJSON { dataResponse in
                            guard dataResponse.response?.statusCode != 401 else {
                                let error = HiveError.failue(des: TOKEN_INVALID)
                                Log.e(TAG(), "Acquiring file %s instance failed: %s", atPath, error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            guard dataResponse.response?.statusCode == 200 else{
                                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                                Log.e(TAG(), "Acquiring file %s instance failed: %s", atPath, error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            let jsonData = JSON(dataResponse.result.value as Any)
                            let fileId = jsonData["id"].stringValue
                            let fileInfo = HiveFileInfo(fileId)
                            fileInfo.installValue(jsonData)
                            let fileHandle = OneDriveFile(fileInfo, self.authHelper)
                            fileHandle.name = jsonData["name"].stringValue
                            fileHandle.pathName = atPath
                            fileHandle.lastInfo = fileInfo
                            fileHandle.drive = self
                            handleBy.didSucceed(fileHandle)
                            resolver.fulfill(fileHandle)
                            Log.d(TAG(), "Acquiring file %s instance succeeded", atPath)
                    }
                }.catch { err in
                    let error = HiveError.failue(des: err.localizedDescription)
                    Log.e(TAG(), "Acquiring file %s instance failed: %s", atPath, error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
                }
            }
            return promise
    }

    private func fullUrl(_ path: String, _ operation: String) -> String {
        if path == "" || path == "/" {
            return OneDriveURL.API + "/root/\(operation)"
        }
        let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        return OneDriveURL.API + "/root:\(ecUrl):/\(operation)"
    }

    private func fullUrl(_ path: String) -> String {
        if path == "" || path == "/" {
            return OneDriveURL.API + "/root"
        }
        let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        return OneDriveURL.API + "/root:\(ecUrl)"
    }
}
