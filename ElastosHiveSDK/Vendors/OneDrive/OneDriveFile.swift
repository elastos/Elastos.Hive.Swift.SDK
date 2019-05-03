import Foundation
import Unirest

@objc(OneDriveFile)
internal class OneDriveFile: HiveFileHandle {
    var oneDrive: OneDrive?

    public override func parentPathName() -> String? {
        guard pathName != nil else {
            return pathName
        }

        let index = pathName!.range(of: "/", options: .backwards)?.lowerBound
        let parentPathname = index.map(pathName!.substring(to:))
        return parentPathname! + "/"
    }

    override func parentHandle(withResult resultHandler: @escaping (HiveFileObjectCreationResponseHandler)) {
        let path: String = parentPathName()!
        do {
            try super.drive?.getFileHandle(atPath: path, withResult: { (hiveFiel, error) in
                resultHandler(hiveFiel, error)
            })
        } catch {
            // TODO
        }
    }

    override func updateDateTime(withValue newValue: String) {
        oneDrive?.authHeperHandle.checkExpired({ (error) in
            if (error != nil) {
//                resultHandler(nil, error)
                return
            }
            let url = "\(ONEDRIVE_RESTFUL_URL)/items/\(self.id!)"
            let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
            let params: Dictionary<String, Any> = ["lastModifiedDateTime": newValue]

            UNIRest.patchEntity { (request) in
                request?.url = url
                request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                request?.body = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                }?.asJsonAsync({ (response, error) in
                    if response?.code == 200 {
                        print(response?.body.jsonObject())
                    }else {
                        print(response?.body.jsonObject())
                    }
                })

        })
    }

    override func copyFileTo(newPath: String, withResult: @escaping HiveResultHandler) throws {
        oneDrive?.authHeperHandle.checkExpired({ (error) in
            if (error != nil) {
                withResult(nil, error)
                return
            }
            if self.pathName == nil {
                withResult(false, .failue(des: "Illegal Argument."))
            }
            if newPath == "" || newPath.isEmpty {
                withResult(false, .failue(des: "Illegal Argument: " + newPath))
            }
            if self.pathName == "/" {
                withResult(false, .failue(des: "This is root file"))
            }
            let parPath = self.parentPathName()
            if newPath == parPath {
                withResult(false, .failue(des: "This file has been existed at the folder: \(newPath)"))
            }
            let path = self.pathName!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var url = ONEDRIVE_RESTFUL_URL + ONEDRIVE_ROOTDIR + ":/" + path + ":/copy"
            if newPath == "/" {
                url = ONEDRIVE_RESTFUL_URL + ONEDRIVE_ROOTDIR + "/copy"
            }
            let components: [String] = (self.pathName!.components(separatedBy: "/"))
            let name = components.last
            var error: NSError?
            let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
            let params: Dictionary<String, Any> = ["parentReference" : ["path": "/drive/root:/\(newPath)"],
                                                   "name": name as Any]
            let globalQueue = DispatchQueue.global()
            globalQueue.async {
                let response = UNIRest.postEntity { (request) in
                    request?.url = url
                    request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                    request?.body = try? JSONSerialization.data(withJSONObject: params)
                    }?.asJson(&error)
                if response?.code == 202 {
                    withResult(true, nil)
                }else {
                    withResult(false, .failue(des: "Invoking the copyTo has error."))
                }
            }
        })
    }

    override func copyFileTo(newFile: HiveFileHandle, withResult: @escaping HiveResultHandler) throws {
        oneDrive?.authHeperHandle.checkExpired({ (error) in
            if (error != nil) {
                withResult(nil, error)
                return
            }
            if self.pathName == nil {
                withResult(false, .failue(des: "Illegal Argument."))
            }
            if self.pathName == "/" {
                withResult(false, .failue(des: "This is root file"))
            }
            let parPath = self.parentPathName()
            if newFile.isEqual(parPath) {
                withResult(false, .failue(des: "This file has been existed at the folder: \(newFile)"))
            }
            // todo judge throw
            guard self.driveId != nil else {
                withResult(false, .failue(des: "Illegal Argument."))
                return
            }
            var url = ONEDRIVE_RESTFUL_URL + "/items/\(self.driveId!)/copy"
            if newFile.isEqual("/") {
                url = ONEDRIVE_RESTFUL_URL + "/copy"
            }

            let components: [String] = (newFile.pathName?.components(separatedBy: "/"))!
            let name = components.last
            var error: NSError?
            let index = self.pathName!.range(of: "/", options: .backwards)?.lowerBound
            let parentPathname = index.map(self.pathName!.substring(to:)) ?? ""
            let name = parentPathname
            let driveId = self.oneDrive?.driveId
            let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
            let params: Dictionary<String, Any> = ["parentReference" : ["driveId": driveId!, "id": driveId],
                                                   "name" : name]
            let globalQueue = DispatchQueue.global()
            globalQueue.async {
                let response = UNIRest.postEntity { (request) in
                    request?.url = url
                    request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                    request?.body = try? JSONSerialization.data(withJSONObject: params)
                    request?.url = url
                    }?.asJson(&error)
                if response?.code == 202 {
                    withResult(true, nil)
                }else {
                    withResult(false, .failue(des: "Invoking the copyTo has error."))
                }
            }
        })
    }

    override func renameFileTo(newPath: String, withResult: @escaping HiveResultHandler) throws {
        oneDrive?.authHeperHandle.checkExpired({ (error) in
            if (error != nil) {
                withResult(nil, error)
                return
            }
            if self.id == nil {
                withResult(false, .failue(des: "Illegal Argument."))
                return
            }
            if self.pathName == "/" {
                withResult(false, .failue(des: "This is root file"))
            }
            let url = "\(ONEDRIVE_RESTFUL_URL)/items/\(self.id!)"
            let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
            let params: Dictionary<String, Any> = ["name": newPath]

                UNIRest.patchEntity { (request) in
                    request?.url = url
                    request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                    request?.body = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                    }?.asJsonAsync({ (response, error) in
                        if response?.code == 200 {
                            withResult(true, nil)
                        }else {
                            withResult(false, .failue(des: "Invoking the rename has error."))
                        }
                    })
        })
    }

    override func renameFileTo(newFile: HiveFileHandle) throws {
        // TODO
    }

    override func deleteItem(withResult: @escaping HiveResultHandler) throws {
        oneDrive?.authHeperHandle.checkExpired({ (error) in
            if (error != nil) {
                withResult(nil, error)
                return
            }
            guard self.id != nil else {
                withResult(false, .failue(des: "Illegal Argument."))
                return
            }
            let globalQueue = DispatchQueue.global()
            globalQueue.async {
                var error: NSError?
                let url: String = ONEDRIVE_RESTFUL_URL + "/items/\(self.id!)"
                let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
                let response = UNIRest.delete { (request) in
                    request?.url = url
                    request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                    }?.asJson(&error)
                if response?.code == 204 {
                    withResult(true, nil)
                }else {
                    withResult(false, .failue(des: "Invoking the delete has error."))
                }
            }
        })
    }

    override func closeItem() throws {
        // TODO
    }

    override func list(withResult: @escaping HiveFileObjectsListResponseHandler) throws {
        oneDrive?.authHeperHandle.checkExpired({ (error) in
            if (error != nil) {
                withResult(nil, error)
                return
            }
            if self.isDirectory == false {
                withResult(nil, nil)
                return
            }
            guard self.id != nil else {
                withResult(nil, .failue(des: "Illegal Argument."))
                return
            }
            let url = ONEDRIVE_RESTFUL_URL + "/items/\(self.id!)/children"
            let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
            UNIRest.get { (request) in
                request?.url = url
                request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                }?.asJsonAsync({ (response, error) in
                    if error != nil || response?.code != 200 {
                        withResult(nil, .jsonFailue(des: (response?.body.jsonObject())!))
                        return
                    }
                    let jsonData = response?.body.jsonObject()
                    if jsonData == nil || jsonData!.isEmpty {
                        withResult(nil,nil)
                        return
                    }
                    let value = jsonData!["value"] as? NSArray
                    if value == nil {
                        withResult(nil, nil)
                        return
                    }
                    var files: Array<HiveFileHandle>? = []
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
                        let sub = valueJson!["parentReference"] as? Dictionary<String, Any>
                        driveFile.parentReference = (sub as! Dictionary<AnyHashable, Any>)
                        driveFile.driveId = (sub!["driveId"] as! String)
                        driveFile.parentId = (sub!["id"] as! String)
                        driveFile.rootPath = ONEDRIVE_RESTFUL_URL + "/root"
                        let fullPath = (sub!["path"] as! String)
                        let end = fullPath.index(fullPath.endIndex, offsetBy: -1)
                        driveFile.parentPath = String(fullPath[..<end])
                        driveFile.pathName = "items/\(ID)"
                        if driveFile.parentId == nil {
                            driveFile.pathName = "/"
                        }
                        files?.append(driveFile)
                    }
                    withResult(files, nil)
                })
        })
    }

    override func mkdir(pathname: String, withResult: @escaping HiveFileObjectCreationResponseHandler) throws {
        oneDrive?.authHeperHandle.checkExpired({ (error) in
            if (error != nil) {
                withResult(nil, error)
                return
            }
            if self.isDirectory == false {
                withResult(nil, .failue(des: "This is a file, can't create a child folder."))
            }
            if self.id == nil {
                withResult(nil, .failue(des: "Illegal Argument."))
            }
            let ID: String = self.id!
            let url: String = "\(ONEDRIVE_RESTFUL_URL)/items/\(ID)/children"
            let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
            let params: Dictionary<String, Any> = ["name": pathname,
                                                   "folder": [: ],
                                                   "@microsoft.graph.conflictBehavior": "rename"]
            UNIRest.postEntity { (request) in
                request?.url = url
                request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                request?.body = try? JSONSerialization.data(withJSONObject: params)
                }?.asJsonAsync({ (response, error) in
                    if response?.code != 201 {
                        let jsonerror = response?.body.jsonObject()
                        withResult(nil, .jsonFailue(des: jsonerror))
                    }
                    let jsonData = response?.body.jsonObject() as? Dictionary<String, Any>
                    if jsonData == nil || jsonData!.isEmpty {
                        withResult(nil, nil)
                    }
                    let driveFile: HiveFileHandle = OneDriveFile()
                    let folder = jsonData!["folder"]
                    if folder != nil {
                        driveFile.isDirectory = true
                        driveFile.isFile = false
                    }
                    driveFile.createdDateTime = (jsonData!["createdDateTime"] as! String)
                    driveFile.lastModifiedDateTime = (jsonData!["lastModifiedDateTime"] as! String)
                    driveFile.fileSystemInfo = (jsonData!["fileSystemInfo"] as! Dictionary)
                    let ID: String = (jsonData!["id"] as! String)
                    driveFile.id = ID
                    let sub = jsonData!["parentReference"] as! NSDictionary
                    driveFile.driveId = (sub["driveId"] as! String)
                    driveFile.parentId = (sub["id"] as! String)
                    driveFile.rootPath = ONEDRIVE_RESTFUL_URL + "/root"
                    let fullPath = (sub["path"] as! String)
                    let end = fullPath.index(fullPath.endIndex, offsetBy: -1)
                    driveFile.parentPath = String(fullPath[..<end])
                    driveFile.pathName = "items/\(ID)"
                    if driveFile.parentId == nil {
                        driveFile.pathName = "/"
                    }
                    withResult(driveFile, nil)
                })
        })
    }

    override func mkdirs(pathname: String) throws {
        // TODO
    }
}
