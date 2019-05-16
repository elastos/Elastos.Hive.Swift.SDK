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

    override func copyTo(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        let future = CallbackFuture<HiveResult<HiveFileHandle>>{ resolver in
            _ = oneDrive?.authHelperHandle.checkExpired()?.done({ (result) in
                if self.pathName == nil {
                    resolver.reject(HiveError.failue(des: "Illegal Argument."))
                }
                if atPath == "" || atPath.isEmpty {
                    resolver.reject(HiveError.failue(des: "Illegal Argument:\(atPath)"))

                }
                if self.pathName == "/" {
                    resolver.reject(HiveError.failue(des: "This is root file"))
                }
                let parPath = self.parentPath
                if atPath == parPath {
                    resolver.reject(HiveError.failue(des: "This file has been existed at the folder: \(atPath)"))
                }
                let path = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                var url = ONEDRIVE_RESTFUL_URL + ONEDRIVE_ROOTDIR + ":/" + path + ":/copy"
                if atPath == "/" {
                    url = ONEDRIVE_RESTFUL_URL + ONEDRIVE_ROOTDIR + "/copy"
                }
                let components: [String] = (self.pathName!.components(separatedBy: "/"))
                let name = components.last
                var error: NSError?
                let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
                let params: Dictionary<String, Any> = ["parentReference" : ["path": "/drive/root:/\(atPath)"],
                                                       "name": name as Any]
                let globalQueue = DispatchQueue.global()
                globalQueue.async {
                    let response = UNIRest.postEntity { (request) in
                        request?.url = url
                        request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
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
        // todo
        return nil
    }

    override func readData() -> CallbackFuture<HiveResult<Data>>? {
        // todo
        return nil
    }

    override func writeData(withData: Data) -> CallbackFuture<HiveResult<Bool>>? {
        // todo
        return nil
    }

    override func renameFileTo(_ atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        let future = CallbackFuture<HiveResult<HiveFileHandle>>{ reslover in
            _ = oneDrive?.authHelperHandle.checkExpired()?.done({ (result) in
                if self.pathName == nil {
                    reslover.reject(HiveError.failue(des: "Illegal Argument."))
                    return
                }
                if self.pathName == "/" {
                    reslover.reject(HiveError.failue(des: "This is root file."))
                }
                let path = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let components: [String] = (atPath.components(separatedBy: "/"))
                let name = components.last
                let url = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):/\(path)"
                let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
                let params: Dictionary<String, Any> = ["name": name as Any]

                UNIRest.patchEntity { (request) in
                    request?.url = url
                    request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                    request?.body = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                    }?.asJsonAsync({ (response, error) in
                        if response?.code == 200 {
                            reslover.fulfill(HiveResult(handle: HiveFileHandle()))
                        }else {
                            reslover.reject(HiveError.failue(des: "Invoking the rename has error."))
                        }
                    })
            })
        }
        return future
    }

    override func renameFileTo(newFile: HiveFileHandle) throws {
        // TODO
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
                    let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
                    let response = UNIRest.delete { (request) in
                        request?.url = url
                        request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                        }?.asJson(&error)
                    if response?.code == 204 {
                        resolver.fulfill(true)
                    }else {
                        resolver.reject(HiveError.failue(des: "Invoking the delete has error."))
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
        let future = CallbackFuture<HiveResult<[HiveFileHandle]>>{ resulover in
            _ = oneDrive?.authHelperHandle.checkExpired()?.done({ (result) in
                //            if self.isDirectory == false {
                //                withResult(nil, nil)
                //                resulover.reject(HiveError.failue(des: <#T##String?#>))
                //                return
                //            }
                guard self.pathName != nil else {
                    resulover.reject(HiveError.failue(des: "Illegal Argument."))
                    return
                }
                let path = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):/\(path):/children"
                let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
                UNIRest.get { (request) in
                    request?.url = url
                    request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                    }?.asJsonAsync({ (response, error) in
                        if error != nil || response?.code != 200 {
                            resulover.reject(HiveError.jsonFailue(des: response?.body.jsonObject()))
                            return
                        }
                        let jsonData = response?.body.jsonObject()
                        if jsonData == nil || jsonData!.isEmpty {
                            resulover.reject(HiveError.failue(des: "response data is nil"))
                            return
                        }
                        let value = jsonData!["value"] as? NSArray
                        if value == nil {
                            resulover.reject(HiveError.failue(des: "response data is nil"))
                            return
                        }
                        let lists = self.handleResult(jsonData! as! Dictionary<String, Any>)
                        resulover.fulfill(HiveResult(handle: lists))
                    })
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
}
