import Foundation
import Unirest
import PromiseKit

@inline(__always) private func TAG() -> String { return "OneDrive" }

internal class OneDriveDrive: HiveDriveHandle {
    private var authHelper: AuthHelper

    init(_ info: HiveDriveInfo, _ authHelper: AuthHelper) {
        self.authHelper = authHelper
        super.init(DriveType.oneDrive, info)
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
            UNIRest.get({ request in
                request?.url = OneDriveURL.API + "/root"
                request?.headers["A"] = "foo"
            })?.asJsonAsync({ (response, error) in
                let jsonObject = response?.body.jsonObject()
                guard response?.code == 200 else {
                    let error = HiveError.jsonFailue(des: response?.body.jsonObject())
                    handleBy.runError(error)
                    resolver.reject(error)
                    return
                }

                let jsonData = jsonObject as? Dictionary<String, String>
                guard jsonData != nil && !jsonData!.isEmpty else {
                    let error = HiveError.systemError(error: error, jsonDes: jsonData)
                    handleBy.runError(error)
                    resolver.reject(error)
                    return
                }

                let info = HiveDirectoryInfo("TODO")
                let handle = OneDriveDirectory(info, self.authHelper);
                handleBy.didSucceed(handle)
                resolver.fulfill(handle)
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

            UNIRest.postEntity({ (request) in
                request?.url = OneDriveURL.API + "/root:\(withPath):/chilldren"
                //request?.headers = self.authHelperHandle.headers()
                request?.body = try? JSONSerialization.data(withJSONObject: params)
            })?.asJsonAsync({ (response, error) in
                let jsonObject = response?.body.jsonObject()
                guard response?.code == 201 else {
                    let error = HiveError.systemError(error: error, jsonDes: jsonObject)
                    handleBy.runError(error)
                    resolver.reject(error)
                    return
                }

                let jsonData = jsonObject as? Dictionary<String, Any>
                guard jsonData != nil && !jsonData!.isEmpty else {
                    let error = HiveError.systemError(error: error, jsonDes: nil)
                    handleBy.runError(error)
                    resolver.reject(error)
                    return
                }

                let info = HiveDirectoryInfo("TODO")
                let handle = OneDriveDirectory(info, self.authHelper)
                handleBy.didSucceed(handle)
                resolver.fulfill(handle)
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
            UNIRest.get({ request in
                request?.url = OneDriveURL.API + "/root:/\(atPath)"
                //request?.headers = self.authHelperHandle.headers()
            })?.asJsonAsync({ (response, error) in
                let jsonObject = response?.body.jsonObject()
                guard response?.code == 200 else {
                    let error = HiveError.jsonFailue(des: jsonObject)
                    handleBy.runError(error)
                    resolver.reject(error)
                    return
                }

                let jsonData = jsonObject as? Dictionary<String, Any>
                guard jsonData != nil && !jsonData!.isEmpty else {
                    let error = HiveError.systemError(error: error, jsonDes: jsonData)
                    handleBy.runError(error)
                    resolver.reject(error)
                    return
                }

                let info = HiveDirectoryInfo("TODO")
                let handle = OneDriveDirectory(info, self.authHelper)
                handleBy.didSucceed(handle)
                resolver.fulfill(handle)
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
            UNIRest.putEntity({ request in
                request?.url = OneDriveURL.API + "/root:/\(withPath):/content"
                //request?.headers = self.authHelperHandle.headers()
            })?.asJsonAsync({ (response, error) in
                let jsonObject = response?.body.jsonObject()
                guard response?.code == 201 else {
                    let error = HiveError.jsonFailue(des: jsonObject)
                    handleBy.runError(error)
                    resolver.reject(error)
                    return
                }

                let jsonData = jsonObject as? Dictionary<String, Any>
                guard jsonData != nil && !jsonData!.isEmpty else {
                    let error = HiveError.systemError(error: error, jsonDes: jsonObject)
                    handleBy.runError(error)
                    resolver.reject(error)
                    return
                }

                let info = HiveFileInfo("TODO")
                let handle = OneDriveFile(info, self.authHelper)
                handleBy.didSucceed(handle)
                resolver.fulfill(handle)
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

    /*
    private func hiveDirectoryHandleResult(_ atPath: String, _ jsonData: Dictionary<String, Any>) -> HiveDirectoryHandle {

        let hiveDirectory = OneDriveDirectory()
        hiveDirectory.drive = self
        hiveDirectory.oneDrive = self
        hiveDirectory.path = atPath
        hiveDirectory.createDateTime = (jsonData["createdDateTime"] as? String)
        hiveDirectory.lastModifiedDateTime = (jsonData["lastModifiedDateTime"] as? String)
        let sub = jsonData["parentReference"] as? NSDictionary
        hiveDirectory.parentReference = (sub as! Dictionary<AnyHashable, Any>)
        let fullPath = sub!["path"]
        if (fullPath != nil) {
            let full = fullPath as!String
            let end = full.index(full.endIndex, offsetBy: -1)
            hiveDirectory.parentPath = String(full[..<end])
        }
        return hiveDirectory
    }

    private func hiveFileHandleResult(_ atPath: String, _ jsonData: Dictionary<String, Any>) -> HiveFileHandle {

        let driveFile: OneDriveFile = OneDriveFile()
        driveFile.drive = self
        driveFile.oneDrive = self
        driveFile.pathName =  atPath
        driveFile.name = (jsonData["name"] as? String)
        let folder = jsonData["folder"]
        if folder != nil {
            driveFile.isDirectory = true
            driveFile.isFile = false
        }
        driveFile.createdDateTime = (jsonData["createdDateTime"] as? String)
        driveFile.lastModifiedDateTime = (jsonData["lastModifiedDateTime"] as? String)
        driveFile.fileSystemInfo = (jsonData["fileSystemInfo"] as? Dictionary)
        driveFile.id = (jsonData["id"] as? String)
        driveFile.rootPath = ONEDRIVE_RESTFUL_URL + "/root"
        let sub = jsonData["parentReference"] as? NSDictionary
        driveFile.parentReference = (sub as! Dictionary<AnyHashable, Any>)
        if (sub != nil) {
            driveFile.driveId = (sub!["driveId"] as? String)
            driveFile.parentId = (sub!["id"] as? String)
        }
        let fullPath = sub!["path"]
        if (fullPath != nil) {
            let full = fullPath as!String
            let end = full.index(full.endIndex, offsetBy: -1)
            driveFile.parentPath = String(full[..<end])
        }
        return driveFile
    }

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
