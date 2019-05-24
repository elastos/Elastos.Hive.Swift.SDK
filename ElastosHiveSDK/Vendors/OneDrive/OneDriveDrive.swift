import Foundation
import Alamofire
import PromiseKit

@inline(__always) private func TAG() -> String { return "OneDrive" }

internal class OneDriveDrive: HiveDriveHandle {
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

    override func lastUpdatedInfo() -> Promise<HiveDriveInfo>? {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>) -> Promise<HiveDriveInfo>? {
        let error = HiveError.failue(des: "TODO")
        return Promise<HiveDriveInfo>(error: error)
    }

    override func rootDirectoryHandle() -> Promise<HiveDirectoryHandle>? {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>)
        -> Promise<HiveDirectoryHandle>? {
            let future = Promise<HiveDirectoryHandle> { resolver in
                Alamofire.request(OneDriveURL.API + "/root", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: (OneDriveHttpHeader.headers())).responseJSON(completionHandler: { (dataResponse) in
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
                        resolver.reject(HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>))
                        handleBy.runError(HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>))
                    }
                })
            }
            return future
    }

    override func createDirectory(withPath: String) -> Promise<HiveDirectoryHandle>? {
        return createDirectory(withPath: withPath,
                               handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> Promise<HiveDirectoryHandle>? {
            let future = Promise<HiveDirectoryHandle> { resolver in
                let params: Dictionary<String, Any> = ["name": withPath as Any,
                                                       "folder": [: ],
                                                       "@microsoft.graph.conflictBehavior": "rename"
                ]
                Alamofire.request(OneDriveURL.API + "/root:\(withPath):/chilldren", method: .post, parameters: params, encoding: JSONEncoding.default, headers: (OneDriveHttpHeader.headers())).responseJSON(completionHandler: { (dataResponse) in
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

    override func directoryHandle(atPath: String) -> Promise<HiveDirectoryHandle>? {
        return directoryHandle(atPath: atPath,
                               handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> Promise<HiveDirectoryHandle>? {
            let future = Promise<HiveDirectoryHandle> { resolver in

                Alamofire.request(OneDriveURL.API + "/root:/\(atPath)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: (OneDriveHttpHeader.headers())).responseJSON(completionHandler: { (dataResponse) in
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

    override func createFile(withPath: String) -> Promise<HiveFileHandle>? {
        return createFile(withPath: withPath,
                          handleBy: HiveCallback<HiveFileHandle>())
    }

    override func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> Promise<HiveFileHandle>? {
            let future = Promise<HiveFileHandle> { resolver in
                Alamofire.request(OneDriveURL.API + "/root:/\(withPath):/content", method: .put, parameters: nil, encoding: JSONEncoding.default, headers: (OneDriveHttpHeader.headers())).responseJSON(completionHandler: { (dataResponse) in
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

    override func fileHandle(atPath: String) -> Promise<HiveFileHandle>? {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        Promise<HiveFileHandle>? {
            let error = HiveError.failue(des: "TODO")
            return Promise<HiveFileHandle>(error: error)
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
        hdirectory.parentReference = parentReference
        hdirectory.createdDateTime = (jsonData["createdDateTime"] as? String) ?? ""
        hdirectory.lastModifiedDateTime = (jsonData["lastModifiedDateTime"] as? String) ?? ""
        let index = atPath.range(of: "/", options: .backwards)?.lowerBound
        let ppName = index.map(atPath.prefix(upTo:)) ?? ""
        if ppName == "" {
            hdirectory.parentPathName = ppName + "/"
        }
        else {
            hdirectory.parentPathName = String(ppName)
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
        hfile.parentReference = (jsonData["parentReference"] as? Dictionary<AnyHashable, Any>) ?? [: ]
        let index = atPath.range(of: "/", options: .backwards)?.lowerBound
        let ppName = index.map(atPath.prefix(upTo:)) ?? ""
        if ppName == "" {
            hfile.parentPathName = ppName + "/"
        }
        else {
            hfile.parentPathName = String(ppName)
        }
        return hfile
    }
    
  /*
    private func validateDrive() throws {
        var error: NSError?
        let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
        let response: UNIHTTPJsonResponse? = UNIRest.get({ (request) in
            request?.url = ONEDRIVE_RESTFUL_URL
            request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
        })?.asJson(&error)
        guard error == nil else {
            return
        }
        guard response?.code == 200 else {
            return
        }
        driveId = (response?.body.jsonObject()["id"] as! String)
    }
    */
}
