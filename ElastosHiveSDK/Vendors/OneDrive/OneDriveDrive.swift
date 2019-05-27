import Foundation
import Alamofire
import PromiseKit

@inline(__always) private func TAG() -> String { return "OneDrive" }

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

    override public func lastUpdatedInfo() -> HivePromise<HiveDriveInfo>? {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>())
    }

    override public func lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>) -> HivePromise<HiveDriveInfo>? {

        let future = HivePromise<HiveDriveInfo> { resolver in
            // root可以获取全部的 HiveDriveInfo info
            Alamofire.request(OneDriveURL.API + "/root", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: (OneDriveHttpHeader.headers())).responseJSON(completionHandler: { (dataResponse) in
                dataResponse.result.ifSuccess {
                    guard dataResponse.response?.statusCode == 200 else{
                        let error = HiveError.failue(des: "result is nil")
                        handleBy.runError(error)
                        resolver.reject(error)
                        return
                    }
                    let jsonData = dataResponse.result.value as? Dictionary<String, Any>
                    guard jsonData != nil else {
                        let error = HiveError.failue(des: "result is nil")
                        handleBy.runError(error)
                        resolver.reject(error)
                        return
                    }
                    let driveInfo = self.hiveDriveInfo(jsonData!)
                    handleBy.didSucceed(driveInfo)
                    resolver.fulfill(driveInfo)
                }
                dataResponse.result.ifFailure {
                    let error = HiveError.failue(des: "result is nil")
                    handleBy.runError(error)
                    resolver.reject(error)
                }
            })
        }
        return future
    }

    override public func rootDirectoryHandle() -> HivePromise<HiveDirectoryHandle>? {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override public func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>? {
            let future = HivePromise<HiveDirectoryHandle> { resolver in
                Alamofire.request(OneDriveURL.API + "/root",
                                  method: .get,
                                  parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON(completionHandler: { (dataResponse) in
                    dataResponse.result.ifSuccess {
                        guard dataResponse.response?.statusCode == 200 else{
                            let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        let jsonData = dataResponse.result.value as? Dictionary<String, Any>
                        guard jsonData != nil else {
                            let error = HiveError.failue(des: "result is nil")
                            handleBy.runError(error)
                            resolver.reject(error)
                            return
                        }
                        let handle = self.hiveDirectoryHandleResult("/", jsonData!)
                        handleBy.didSucceed(handle)
                        resolver.fulfill(handle)
                    }
                    dataResponse.result.ifFailure {
                        let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                        resolver.reject(error)
                        handleBy.runError(error)
                    }
                })
            }
            return future
    }

    override public func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle>? {
        return createDirectory(withPath: withPath,
                               handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override public func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>? {
            let future = HivePromise<HiveDirectoryHandle> { resolver in
                let params: Dictionary<String, Any> = ["name": HelperMethods.endPath(withPath) as Any,
                                                       "folder": [: ],
                                                       "@microsoft.graph.conflictBehavior": "fail"
                ]
                let url = perUrl(withPath, "children")
                Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: (OneDriveHttpHeader.headers())).responseJSON(completionHandler: { (dataResponse) in
                    dataResponse.result.ifSuccess {
                        guard dataResponse.response?.statusCode == 201 else{
                            let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        let jsonData = dataResponse.result.value as? Dictionary<String, Any>
                        guard jsonData != nil else {
                            let error = HiveError.failue(des: "result is nil")
                            handleBy.runError(error)
                            resolver.reject(error)
                            return
                        }
                        let handle = self.hiveDirectoryHandleResult(withPath, jsonData!)
                        handleBy.didSucceed(handle)
                        resolver.fulfill(handle)
                    }
                    dataResponse.result.ifFailure {
                        let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                        resolver.reject(error)
                        handleBy.runError(error)
                    }
                })
            }
            return future
    }

    override public func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle>? {
        return directoryHandle(atPath: atPath,
                               handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override public func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>? {
            let future = HivePromise<HiveDirectoryHandle> { resolver in
                let url = fullUrl(atPath)
                Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: (OneDriveHttpHeader.headers())).responseJSON(completionHandler: { (dataResponse) in
                    dataResponse.result.ifSuccess {
                        guard dataResponse.response?.statusCode == 200 else{
                            let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        let jsonData = dataResponse.result.value as? Dictionary<String, Any>
                        guard jsonData != nil else {
                            let error = HiveError.failue(des: "result is nil")
                            handleBy.runError(error)
                            resolver.reject(error)
                            return
                        }
                        let handle = self.hiveDirectoryHandleResult(atPath, jsonData!)
                        handleBy.didSucceed(handle)
                        resolver.fulfill(handle)
                    }
                    dataResponse.result.ifFailure {
                        let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                        resolver.reject(error)
                        handleBy.runError(error)
                    }
                })
            }
            return future
    }

    override public func createFile(withPath: String) -> HivePromise<HiveFileHandle>? {
        return createFile(withPath: withPath,
                          handleBy: HiveCallback<HiveFileHandle>())
    }

    override public func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>? {
            let future = HivePromise<HiveFileHandle> { resolver in
                let url = fullUrl(withPath, "content")
                Alamofire.request(url, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: (OneDriveHttpHeader.headers())).responseJSON(completionHandler: { (dataResponse) in
                    dataResponse.result.ifSuccess {
                        guard dataResponse.response?.statusCode == 200 || dataResponse.response?.statusCode == 201 else{
                            let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        let jsonData = dataResponse.result.value as? Dictionary<String, Any>
                        guard jsonData != nil else {
                            let error = HiveError.failue(des: "result is nil")
                            handleBy.runError(error)
                            resolver.reject(error)
                            return
                        }
                        let handle = self.hiveFileHandleResult(withPath, jsonData!)
                        handleBy.didSucceed(handle)
                        resolver.fulfill(handle)
                    }
                    dataResponse.result.ifFailure {
                        let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                        resolver.reject(error)
                        handleBy.runError(error)
                    }
                })
            }
            return future
    }

    override public func fileHandle(atPath: String) -> HivePromise<HiveFileHandle>? {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override public func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle>? {
                let future = HivePromise<HiveFileHandle> { resolver in
                    let url = fullUrl(atPath)
                    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: (OneDriveHttpHeader.headers())).responseJSON(completionHandler: { (dataResponse) in
                        dataResponse.result.ifSuccess {
                            guard dataResponse.response?.statusCode == 200 else{
                                let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            let jsonData = dataResponse.result.value as? Dictionary<String, Any>
                            guard jsonData != nil else {
                                let error = HiveError.failue(des: "result is nil")
                                handleBy.runError(error)
                                resolver.reject(error)
                                return
                            }
                            let handle = self.hiveFileHandleResult(atPath, jsonData!)
                            handleBy.didSucceed(handle)
                            resolver.fulfill(handle)
                        }
                        dataResponse.result.ifFailure {
                            let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                            resolver.reject(error)
                            handleBy.runError(error)
                        }
                    })
                }
                return future
    }

    private func perUrl(_ path: String, _ operation: String) -> String {
        let ph = HelperMethods.prePath(path)
        if ph == "" || ph == "/" {
            return OneDriveURL.API + "/root/\(operation)"
        }
        else {
            let ecUrl = ph.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            return OneDriveURL.API + "/root:\(ecUrl):/\(operation)"
        }
    }

    private func fullUrl(_ path: String, _ operation: String) -> String {
        if path == "" || path == "/" {
            return OneDriveURL.API + "/root/\(operation)"
        }
        else {
            let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            return OneDriveURL.API + "/root:\(ecUrl):/\(operation)"
        }
    }

    private func fullUrl(_ path: String) -> String {
        if path == "" || path == "/" {
            return OneDriveURL.API + "/root"
        }
        else {
            let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            return OneDriveURL.API + "/root:\(ecUrl)"
        }
    }

    private func hiveDriveInfo(_ jsonData: Dictionary<String, Any>) -> HiveDriveInfo {
        let driveInfo = HiveDriveInfo()
        let quota = jsonData["quota"] as? Dictionary<String, Any> ?? [: ]
        driveInfo.capacity = quota["total"] as? String ?? ""
        driveInfo.used = quota["used"] as? String ?? ""
        driveInfo.remaining = quota["remaining"] as? String ?? ""
        driveInfo.deleted = quota["deleted"] as? String ?? ""
        let stat = jsonData["state"] as? String ?? ""
        driveInfo.state = stat
        if stat == "normal" {
            driveInfo.driveState = .normal
        }else if stat == "nearing" {
            driveInfo.driveState = .nearing
        }else if stat == "critical" {
            driveInfo.driveState = .critical
        }else if stat == "exceeded" {
            driveInfo.driveState = .exceeded
        }
        driveInfo.lastModifiedDateTime = jsonData["lastModifiedDateTime"] as? String ?? ""
        let folder = jsonData["folder"] as? Dictionary<String, Any> ?? [: ]
        driveInfo.fileCount = folder["childCount"] as? String ?? ""
        driveInfo.ddescription = ""
        return driveInfo
    }

    private func hiveDirectoryHandleResult(_ atPath: String, _ jsonData: Dictionary<String, Any>) -> HiveDirectoryHandle {

        let parentReference = jsonData["parentReference"] as? Dictionary<String, Any> ?? [:]
        let driveId = parentReference["driveId"]
        let hdInfo = HiveDirectoryInfo(driveId as? String ?? "")
        let hdirectory = OneDriveDirectory(hdInfo, self.authHelper)
        hdirectory.drive = self
        hdirectory.oneDrive = self
        hdirectory.directoryId = (jsonData["id"] as? String) ?? ""
        hdirectory.pathName = atPath
        hdirectory.name = (jsonData["name"] as? String) ?? ""
        hdirectory.parentReference = parentReference
        hdirectory.createdDateTime = (jsonData["createdDateTime"] as? String) ?? ""
        hdirectory.lastModifiedDateTime = (jsonData["lastModifiedDateTime"] as? String) ?? ""
        let fullPath = parentReference["path"] as? String ?? ""
        let parentPathName = fullPath.split(separator: ":", maxSplits: 1).map(String.init).last
        hdirectory.parentPathName = parentPathName
        if fullPath == "/drive/root:" {
            hdirectory.parentPathName = "/"
        }
        return hdirectory
    }

    private func hiveFileHandleResult(_ atPath: String, _ jsonData: Dictionary<String, Any>) -> HiveFileHandle {

        let fileId = (jsonData["id"] as? String) ?? ""
        let hfInfo = HiveFileInfo(fileId)
        let hfile: OneDriveFile = OneDriveFile(hfInfo, self.authHelper)
        hfile.drive = self
        hfile.pathName =  atPath
        hfile.name = (jsonData["name"] as? String) ?? ""
        hfile.createdDateTime = (jsonData["createdDateTime"] as? String)
        hfile.lastModifiedDateTime = (jsonData["lastModifiedDateTime"] as? String)
        hfile.fileSystemInfo = (jsonData["fileSystemInfo"] as? Dictionary)
        let parentReference = jsonData["parentReference"] as? Dictionary<String, Any> ?? [:]
        hfile.parentReference = parentReference
        let fullPath = parentReference["path"] as? String ?? ""
        let parentPathName = fullPath.split(separator: ":", maxSplits: 1).map(String.init).last
        hfile.parentPathName = parentPathName
        if fullPath == "/drive/root:" {
            hfile.parentPathName = "/"
        }
        return hfile
    }
}
