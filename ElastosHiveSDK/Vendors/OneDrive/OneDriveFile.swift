import Foundation
import Unirest

@objc(OneDriveFile)
internal class OneDriveFile: HiveFileHandle {
    var oneDrive: OneDrive?

    override func parentHandle() -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        let future = CallbackFuture<HiveResult<HiveDirectoryHandle>> { resolver in
            let path = parentPath
            _ = self.drive?.directoryHandle(atPath: path!)?.done({ (hiveDirectoryHandle) in
                resolver.fulfill(hiveDirectoryHandle)
            })
        }
        return future
    }

    override func createFile(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        let fulture = CallbackFuture<HiveResult<HiveFileHandle>>{ resolver in
            if oneDrive!.authHelperHandle.authInfo == nil {
                resolver.reject(HiveError.failue(des: "Please login first"))
                return
            }
            _ = oneDrive!.authHelperHandle.checkExpired()?.done({ (result) in
                if result {
                    UNIRest.putEntity { (request) in
                        request?.url = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):/\(atPath):/content"
                        request?.headers = self.oneDrive!.authHelperHandle.headers()
                        }?.asJsonAsync({ (response, error) in
                            if response?.code != 201 {
                                resolver.reject(HiveError.jsonFailue(des: response?.body.jsonObject()))
                                return
                            }
                            let jsonData = response?.body.jsonObject() as? Dictionary<String, Any>
                            if self.validateJsonData(jsonData) == false {
                                resolver.reject(HiveError.systemError(error: error, jsonDes: response?.body.jsonObject()))
                                return
                            }
                            let hiveDirectoryHandle = self.oneDrive!.handleResult(atPath, jsonData!)
                            resolver.fulfill(HiveResult(handle: hiveDirectoryHandle.hiveFile!))
                        })
                }
            })
        }
        return fulture
    }

    override func copyTo(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        let future = CallbackFuture<HiveResult<HiveFileHandle>>{ resolver in
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
                        resolver.fulfill(HiveResult(handle: HiveFileHandle())) // todo
                    }else {
                        resolver.reject(HiveError.failue(des: "Invoking the copyTo has error."))
                    }
                }
            })
        }
        return future
    }

    override func moveTo(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        let future = CallbackFuture<HiveResult<HiveFileHandle>>{ resolver in
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
                            resolver.fulfill(HiveResult(handle: HiveFileHandle()))
                        }else {
                            resolver.reject(HiveError.failue(des: "Invoking the rename has error."))
                        }
                    })
            })
        }
        return future
    }

    override func readData() -> CallbackFuture<HiveResult<Data>>? {
        // todo
        return nil
    }

    override func writeData(withData: Data) -> CallbackFuture<HiveResult<Bool>>? {
        // todo
        return nil
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

    override func close() {
        // TODO
    }

    // todo
    override func list() -> CallbackFuture<HiveResult<[HiveFileHandle]>>? {
        let future = CallbackFuture<HiveResult<[HiveFileHandle]>>{ resolver in
            _ = oneDrive?.authHelperHandle.checkExpired()?.done({ (result) in
                guard self.pathName != nil else {
                    resolver.reject(HiveError.failue(des: "Illegal Argument."))
                    return
                }
                let path = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):/\(path):/children"
                UNIRest.get { (request) in
                    request?.url = url
                    request?.headers = self.oneDrive!.authHelperHandle.headers()
                    }?.asJsonAsync({ (response, error) in
                        if error != nil || response?.code != 200 {
                            resolver.reject(HiveError.jsonFailue(des: response?.body.jsonObject()))
                            return
                        }
                        let jsonData = response?.body.jsonObject() as? Dictionary<String, Any>
                        if self.validateJsonData(jsonData) == false {
                            resolver.reject(HiveError.systemError(error: error, jsonDes: response?.body.jsonObject()))
                            return
                        }
                        let value = jsonData!["value"] as? NSArray
                        if value == nil {
                            resolver.reject(HiveError.failue(des: "response data is nil"))
                            return
                        }
                        let lists = self.handleResult(jsonData!)
                        resolver.fulfill(HiveResult(handle: lists))
                    })
            }).catch({ (error) in
                resolver.reject(error)
            })
        }
        return future
    }

    private func handleResult(_ jsonData: Dictionary<String, Any>) -> [HiveFileHandle] {

        var files: Array<HiveFileHandle>? = []
        let value = jsonData["value"] as? NSArray
        for va in value! {
            let valueJson = va as? Dictionary<String, Any>
            let driveFile: HiveFileHandle = OneDriveFile()
            let folder = valueJson!["folder"]
            if folder != nil {
                driveFile.isDirectory = true
                driveFile.isFile = false
            }
            driveFile.createdDateTime = (valueJson!["createdDateTime"] as! String)
            driveFile.lastModifiedDateTime = (valueJson!["lastModifiedDateTime"] as! String)
            driveFile.fileSystemInfo = (valueJson!["fileSystemInfo"] as! Dictionary)
            let ID: String = (valueJson!["id"] as! String)
            driveFile.id = ID
            let sub = valueJson!["parentReference"] as? Dictionary<AnyHashable, Any>
            driveFile.parentReference = sub
            driveFile.driveId = (sub!["driveId"] as! String)
            driveFile.parentId = (sub!["id"] as! String)
            driveFile.rootPath = ONEDRIVE_RESTFUL_URL + "/root"
            let fullPath = (sub!["path"] as! String)
            let end = fullPath.index(fullPath.endIndex, offsetBy: -1)
            driveFile.parentPath = String(fullPath[..<end])
            driveFile.pathName = "items/\(ID)"
            driveFile.name = (jsonData["name"] as? String)
            if driveFile.parentId == nil {
                driveFile.pathName = "/"
            }
            files?.append(driveFile)
        }
        return files!
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
}
