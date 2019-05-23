import Foundation
import PromiseKit
import Unirest

class OneDriveDirectory: HiveDirectoryHandle {
    //var oneDrive: OneDrive?

    override init(_ info: HiveDirectoryInfo, _ authHelper: AuthHelper) {
        super.init(info, authHelper)
    }

    override func lastUpdatedInfo() -> Promise<HiveDirectoryInfo>? {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryInfo>) -> Promise<HiveDirectoryInfo>? {
        let error = HiveError.failue(des: "TODO")
        return Promise<HiveDirectoryInfo>(error: error)
    }

    override func createDirectory(withPath: String) -> Promise<HiveDirectoryHandle>? {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        Promise<HiveDirectoryHandle>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveDirectoryHandle>(error: error)
    }

    override func directoryHandle(atPath: String) -> Promise<HiveDirectoryHandle>? {
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        Promise<HiveDirectoryHandle>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveDirectoryHandle>(error: error)
    }

    override func createFile(withPath: String) -> Promise<HiveFileHandle>? {
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        Promise<HiveFileHandle>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveFileHandle>(error: error)
    }

    override func fileHandle(atPath: String) -> Promise<HiveFileHandle>? {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        Promise<HiveFileHandle>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveFileHandle>(error: error)
    }
    // Get children.

    override func moveTo(newPath: String) -> Promise<HiveStatus>? {
        return moveTo(newPath: newPath, handleBy: HiveCallback<HiveStatus>())
    }

    override func moveTo(newPath: String, handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveStatus>(error: error)
    }

    override func copyTo(newPath: String) -> Promise<HiveStatus>? {
        return copyTo(newPath: newPath, handleBy: HiveCallback<HiveStatus>())
    }

    override func copyTo(newPath: String, handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveStatus>(error: error)
    }

    override func deleteItem() -> Promise<HiveStatus>? {
        return deleteItem(handleBy: HiveCallback<HiveStatus>())
    }

    override func deleteItem(handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveStatus>(error: error)
    }

    override func close() {
        // TODO
    }

    /*override func parentHandle() -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        let future = CallbackFuture<HiveResult<HiveDirectoryHandle>> { resolver in
            let path = parentPath
            _ = self.drive?.directoryHandle(atPath: path!)?.done({ (hiveDirectoryHandle) in
                resolver.fulfill(hiveDirectoryHandle)
            })
        }
        return future
    }

    override func createDirectory(atName: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        let future = CallbackFuture<HiveResult<HiveDirectoryHandle>> { resolver in

            if oneDrive!.authHelperHandle.authInfo == nil {
                print("Please login first")
                resolver.reject(HiveError.failue(des: "error"))
                return
            }
            _ = oneDrive!.authHelperHandle.checkExpired()!.done({ (result) in
                if result {
                    let path = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    let params: Dictionary<String, Any> = ["name": atName as Any,
                                                           "folder": [: ],
                                                           "@microsoft.graph.conflictBehavior": "rename"]
                    UNIRest.postEntity { (request) in
                        request?.url = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):/\(path):/children"
                        request?.headers = self.oneDrive!.authHelperHandle.headers()
                        request?.body = try? JSONSerialization.data(withJSONObject: params)
                        }?.asJsonAsync({ (response, error) in
                            if response?.code != 201 {
                                resolver.reject(HiveError.systemError(error: error, jsonDes: response?.body.jsonObject()))
                                return
                            }
                            let jsonData = response?.body.jsonObject() as? Dictionary<String, Any>
                            if jsonData == nil || jsonData!.isEmpty {
                                resolver.reject(HiveError.systemError(error: error, jsonDes: nil))
                                return
                            }
                            let hiveDirectoryHandle = self.hiveDirectoryHandleResult(atName, jsonData!)
                            resolver.fulfill(HiveResult(handle: hiveDirectoryHandle))
                        })
                }
            })
        }
        return future
    }

    override func getDirectory(atName: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        let fulture = CallbackFuture<HiveResult<HiveDirectoryHandle>>{ resolver in
            if oneDrive!.authHelperHandle.authInfo == nil {
                resolver.reject(HiveError.failue(des: "Please login first"))
                return
            }
            _ = oneDrive!.authHelperHandle.checkExpired()?.done({ (result) in
                let url = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):/\(self.pathName!)"
                UNIRest.get({ (request) in
                    request?.url = url
                    request?.headers = self.oneDrive!.authHelperHandle.headers()
                })?.asJsonAsync({ (response, error) in
                    if response?.code != 200 {
                        resolver.reject(HiveError.jsonFailue(des: response?.body.jsonObject()))
                        return
                    }
                    let jsonData = response?.body.jsonObject() as? Dictionary<String, Any>
                    if jsonData == nil || jsonData!.isEmpty {
                        resolver.reject(HiveError.systemError(error: error, jsonDes: jsonData))
                        return
                    }
                    let hiveDirectoryHandle = self.hiveDirectoryHandleResult(atName, jsonData!)
                    resolver.fulfill(HiveResult(handle: hiveDirectoryHandle))
                })
            })
        }
        return fulture
    }

    override func createFile(atName: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        let fulture = CallbackFuture<HiveResult<HiveFileHandle>>{ resolver in
            if oneDrive!.authHelperHandle.authInfo == nil {
                resolver.reject(HiveError.failue(des: "Please login first"))
                return
            }
            _ = oneDrive!.authHelperHandle.checkExpired()?.done({ (result) in
                if result {
                    UNIRest.putEntity { (request) in
                        request?.url = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):/\(self.pathName!):/content"
                        request?.headers = self.oneDrive!.authHelperHandle.headers()
                        }?.asJsonAsync({ (response, error) in
                            if response?.code != 201 {
                                resolver.reject(HiveError.jsonFailue(des: response?.body.jsonObject()))
                                return
                            }
                            let jsonData = response?.body.jsonObject() as? Dictionary<String, Any>
                            if jsonData == nil || jsonData!.isEmpty {
                                resolver.reject(HiveError.systemError(error: error, jsonDes: response?.body.jsonObject()))
                                return
                            }
                            let hiveFileHandle = self.hiveFileHandleResult(atName, jsonData!)
                            resolver.fulfill(HiveResult(handle: hiveFileHandle))
                        })
                }
            })
        }
        return fulture
    }

    override func fileHandle(atName: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        // todo
        return nil
    }

    override func moveTo(atPath: String) -> CallbackFuture<Bool>? {
        let future = CallbackFuture<Bool>{ resolver in
            _ = oneDrive?.authHelperHandle.checkExpired()?.done({ (result) in
                if self.validatePath(atPath).0 == false {
                    resolver.reject(HiveError.failue(des: self.validatePath(atPath).1))
                    return
                }
                let path = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let components: [String] = (atPath.components(separatedBy: "/"))
                let name = components.last
                let url = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):/\(path)"
                let params: Dictionary<String, Any> = ["name": name as Any]

                UNIRest.patchEntity { (request) in
                    request?.url = url
                    request?.headers = self.oneDrive!.authHelperHandle.headers()
                    request?.body = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                    }?.asJsonAsync({ (response, error) in
                        if response?.code == 200 {
                            resolver.fulfill(true)
                        }else {
                            resolver.reject(HiveError.failue(des: "Invoking the rename has error."))
                        }
                    })
            })
        }
        return future
    }

    override func copyTo(atPath: String) -> CallbackFuture<Bool>? {
        let future = CallbackFuture<Bool>{ resolver in
            _ = oneDrive?.authHelperHandle.checkExpired()?.done({ (result) in
                if self.validatePath(atPath).0 == false {
                    resolver.reject(HiveError.failue(des: self.validatePath(atPath).1))
                    return
                }
                let path = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                var url = ONEDRIVE_RESTFUL_URL + ONEDRIVE_ROOTDIR + ":/" + path + ":/copy"
                if atPath == "/" {
                    url = ONEDRIVE_RESTFUL_URL + ONEDRIVE_ROOTDIR + "/copy"
                }
                let name = self.getName()
                var error: NSError?
                let params: Dictionary<String, Any> = ["parentReference" : ["path": "/drive/root:/\(atPath)"],
                                                       "name": name as Any]
                let globalQueue = DispatchQueue.global()
                globalQueue.async {
                    let response = UNIRest.postEntity { (request) in
                        request?.url = url
                        request?.headers = self.oneDrive!.authHelperHandle.headers()
                        request?.body = try? JSONSerialization.data(withJSONObject: params)
                        }?.asJson(&error)
                    if response?.code == 202 {
                        resolver.fulfill(true) // todo
                    }else {
                        resolver.reject(HiveError.failue(des: "Invoking the copyTo has error."))
                    }
                }
            })
        }
        return future
    }

    override func deleteItem() -> CallbackFuture<Bool>? {
        let future = CallbackFuture<Bool>{ resolver in
            _ = oneDrive?.authHelperHandle.checkExpired()?.done({ (result) in
                guard self.pathName != nil else {
                    resolver.reject(HiveError.failue(des: "Illegal Argument."))
                    return
                }
                let globalQueue = DispatchQueue.global()
                globalQueue.async {
                    var error: NSError?
                    let path = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    let url: String = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):/\(path)"
                    let response = UNIRest.delete { (request) in
                        request?.url = url
                        request?.headers = self.oneDrive!.authHelperHandle.headers()
                        }?.asJson(&error)
                    if response?.code == 204 {
                        resolver.fulfill(true)
                    }else {
                        resolver.reject(HiveError.failue(des: "Invoking the delete has error."))
                        return
                    }
                }
            })
        }
        return future
    }

    private func hiveDirectoryHandleResult(_ atPath: String, _ jsonData: Dictionary<String, Any>) -> HiveDirectoryHandle {

        let hiveDirectory = OneDriveDirectory()
        hiveDirectory.drive = self.drive
        hiveDirectory.oneDrive = (self.drive as! OneDrive)
        hiveDirectory.pathName = atPath
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
        driveFile.drive = self.drive
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


    private func validatePath(_ atPath: String) -> (Bool, String) {

        if self.pathName == nil || atPath == "" || atPath.isEmpty {
            return (false, "Illegal Argument.")
        }
        if self.pathName == "/" {
            return (false, "This is root file")
        }
        return (true, "")
    }

    private func getName() -> String {
        let components: [String] = (self.pathName!.components(separatedBy: "/"))
        let name = components.last
        return name ?? ""
    }

    private func validateJsonData(_ jsonData: Dictionary<String, Any>?) -> Bool{
        if jsonData == nil || jsonData!.isEmpty {
            return false
        }
        return true
    }

    internal func handleResult(_ atPath: String, _ jsonData: Dictionary<String, Any>) -> HiveFileHandle {
        let driveFile: OneDriveFile = OneDriveFile()
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

    */
}
