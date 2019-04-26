import Foundation
import Unirest

@objc(OneDriveFile)
internal class OneDriveFile: HiveFileHandle {

    var oneDrive: OneDrive?

    public override func parentPathName() -> String? {

        if pathName == nil {
            return nil
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
        }
    }

    override func updateDateTime(withValue newValue: String) {
        oneDrive?.authHeperHandle.checkExpired({ (error) in
            if (error != nil) {
//                resultHandler(nil, error)
                return
            }
            let url = "\(RESTAPI_URL)/items/\(self.id!)"
            let accesstoken = HelperMethods.getkeychain(ACCESS_TOKEN, ONEDRIVE_ACCOUNT) ?? ""
            let params: Dictionary<String, Any> = ["lastModifiedDateTime": newValue]

            UNIRest.patchEntity { (request) in
                request?.url = url
                request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
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

    override func copyFileTo(newPath: String, result: @escaping HiveFileHandle.HandleResulr) throws {

        oneDrive?.authHeperHandle.checkExpired({ (error) in
            if (error != nil) {
                result(nil, error)
                return
            }
            if self.pathName == nil {
                result(false, .failue(des: "Illegal Argument."))
            }
            if newPath == "" || newPath.isEmpty {
                result(false, .failue(des: "Illegal Argument: " + newPath))
            }
            if self.pathName == "/" {
                result(false, .failue(des: "This is root file"))
            }
            let parPath = self.parentPathName()
            if newPath == parPath {
                result(false, .failue(des: "This file has been existed at the folder: \(newPath)"))
            }

            var url = RESTAPI_URL + ROOT_DIR + ":/" + newPath + ":/copy"
            if newPath == "/" {
                url = RESTAPI_URL + ROOT_DIR + "/copy"
            }
            let index = self.pathName!.range(of: "/", options: .backwards)?.lowerBound
            let parentPathname = index.map(self.pathName!.substring(to:)) ?? ""
            let name = parentPathname
            var error: NSError?
            let driveId = self.oneDrive?.driveId
            let accesstoken = HelperMethods.getkeychain(ACCESS_TOKEN, ONEDRIVE_ACCOUNT) ?? ""
            let params: Dictionary<String, Any> = ["parentReference" : ["driveId": driveId!, "id": driveId],
                                                   "name" : name]
            let globalQueue = DispatchQueue.global()
            globalQueue.async {
                let response = UNIRest.postEntity { (request) in
                    request?.url = url
                    request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                    request?.body = try? JSONSerialization.data(withJSONObject: params)
                    }?.asJson(&error)
                if response?.code == 202 {
                    result(true, nil)
                }else {
                    result(false, .failue(des: "Invoking the copyTo has error."))
                }
            }
        })
    }
    
    override func copyFileTo(newFile: HiveFileHandle, result: @escaping HiveFileHandle.HandleResulr) throws {
        oneDrive?.authHeperHandle.checkExpired({ (error) in
            if (error != nil) {
                result(nil, error)
                return
            }
            if self.pathName == nil {
                result(false, .failue(des: "Illegal Argument."))
            }
            if self.pathName == "/" {
                result(false, .failue(des: "This is root file"))
            }
            let parPath = self.parentPathName()
            if newFile.isEqual(parPath) {
                result(false, .failue(des: "This file has been existed at the folder: \(newFile)"))
            }
            // todo judge throw
            guard self.driveId == nil else {
                result(false, .failue(des: "Illegal Argument."))
                return
            }
            var url = RESTAPI_URL + "/items/\(self.driveId!)/copy"
            if newFile.isEqual("/") {
                url = RESTAPI_URL + "/copy"
            }
            var error: NSError?
            let index = self.pathName!.range(of: "/", options: .backwards)?.lowerBound
            let parentPathname = index.map(self.pathName!.substring(to:)) ?? ""
            let name = parentPathname
            let driveId = self.oneDrive?.driveId
            let accesstoken = HelperMethods.getkeychain(ACCESS_TOKEN, ONEDRIVE_ACCOUNT) ?? ""
            let params: Dictionary<String, Any> = ["parentReference" : ["driveId": driveId!, "id": driveId],
                                                   "name" : name]
            let globalQueue = DispatchQueue.global()
            globalQueue.async {
                let response = UNIRest.postEntity { (request) in
                    request?.url = url
                    request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                    request?.body = try? JSONSerialization.data(withJSONObject: params)
                    }?.asJson(&error)
                if response?.code == 202 {
                    result(true, nil)
                }else {
                    result(false, .failue(des: "Invoking the copyTo has error."))
                }
            }
        })
    }

    override func renameFileTo(newPath: String, result: @escaping HiveFileHandle.HandleResulr) throws {
        oneDrive?.authHeperHandle.checkExpired({ (error) in
            if (error != nil) {
                result(nil, error)
                return
            }
            if self.id == nil {
                result(false, .failue(des: "Illegal Argument."))
                return
            }
            if self.pathName == "/" {
                result(false, .failue(des: "This is root file"))
            }
            let url = "\(RESTAPI_URL)/items/\(self.id!)"
            let accesstoken = HelperMethods.getkeychain(ACCESS_TOKEN, ONEDRIVE_ACCOUNT) ?? ""
            let params: Dictionary<String, Any> = ["name": newPath]

                UNIRest.patchEntity { (request) in
                    request?.url = url
                    request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                    request?.body = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                    }?.asJsonAsync({ (response, error) in
                        if response?.code == 200 {
                            result(true, nil)
                        }else {
                            result(false, .failue(des: "Invoking the rename has error."))
                        }
                    })
        })
    }

    override func renameFileTo(newFile: HiveFileHandle) throws {
        // TODO
    }

    override func deleteItem(result: @escaping HiveFileHandle.HandleResulr) throws {
        oneDrive?.authHeperHandle.checkExpired({ (error) in
            if (error != nil) {
                result(nil, error)
                return
            }
            guard self.id != nil else {
                result(false, .failue(des: "Illegal Argument."))
                return
            }
            let globalQueue = DispatchQueue.global()
            globalQueue.async {
                var error: NSError?
                let url: String = RESTAPI_URL + "/items/\(self.id!)"
                let accesstoken = HelperMethods.getkeychain(ACCESS_TOKEN, ONEDRIVE_ACCOUNT) ?? ""
                let response = UNIRest.delete { (request) in
                    request?.url = url
                    request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                    }?.asJson(&error)
                if response?.code == 204 {
                    result(true, nil)
                }else {
                    result(false, .failue(des: "Invoking the delete has error."))
                }
            }
        })
    }

    override func closeItem() throws {
        // TODO
    }

    override func list(result: @escaping HiveFileHandle.HandleResulrWithFiles) throws {
        oneDrive?.authHeperHandle.checkExpired({ (error) in
            if (error != nil) {
                result(nil, error)
                return
            }
            if self.isDirectory == false {
                result(nil, nil)
                return
            }
            guard self.id != nil else {
                result(nil, .failue(des: "Illegal Argument."))
                return
            }
            let url = RESTAPI_URL + "/items/\(self.id!)/children"
            let accesstoken = HelperMethods.getkeychain(ACCESS_TOKEN, ONEDRIVE_ACCOUNT) ?? ""
            UNIRest.get { (request) in
                request?.url = url
                request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                }?.asJsonAsync({ (response, error) in
                    if error != nil || response?.code != 200 {
                        result(nil, .jsonFailue(des: (response?.body.jsonObject())!))
                        return
                    }
                    let jsonData = response?.body.jsonObject()
                    if jsonData == nil || jsonData!.isEmpty {
                        result(nil,nil)
                        return
                    }
                    let value = jsonData!["value"] as? NSArray
                    if value == nil {
                        result(nil, nil)
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
                        driveFile.driveId = (sub!["driveId"] as! String)
                        driveFile.parentId = (sub!["id"] as! String)
                        driveFile.rootPath = RESTAPI_URL + "/root"
                        let fullPath = (sub!["path"] as! String)
                        let end = fullPath.index(fullPath.endIndex, offsetBy: -1)
                        driveFile.parentPath = String(fullPath[..<end])
                        driveFile.pathName = "items/\(ID)"
                        if driveFile.parentId == nil {
                            driveFile.pathName = "/"
                        }
                        files?.append(driveFile)
                    }
                    result(files, nil)
                })
        })
    }

    override func mkdir(pathname: String, result: @escaping HiveFileHandle.HandleResulrWithFile) throws {
        oneDrive?.authHeperHandle.checkExpired({ (error) in
            if (error != nil) {
                result(nil, error)
                return
            }
            if self.isDirectory == false {
                result(nil, .failue(des: "This is a file, can't create a child folder."))
            }
            if self.id == nil {
                result(nil, .failue(des: "Illegal Argument."))
            }
            let ID: String = self.id!
            let url: String = "\(RESTAPI_URL)/items/\(ID)/children"
            let accesstoken = HelperMethods.getkeychain(ACCESS_TOKEN, ONEDRIVE_ACCOUNT) ?? ""
            let params: Dictionary<String, Any> = ["name": pathname,
                                                   "folder": [: ],
                                                   "@microsoft.graph.conflictBehavior": "rename"]
            UNIRest.postEntity { (request) in
                request?.url = url
                request?.headers = ["Content-Type": "application/json;charset=UTF-8", HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                request?.body = try? JSONSerialization.data(withJSONObject: params)
                }?.asJsonAsync({ (response, error) in
                    if response?.code != 201 {
                        let jsonerror = response?.body.jsonObject()
                        result(nil, .jsonFailue(des: jsonerror))
                    }
                    let jsonData = response?.body.jsonObject() as? Dictionary<String, Any>
                    if jsonData == nil || jsonData!.isEmpty {
                        result(nil, nil)
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
                    driveFile.rootPath = RESTAPI_URL + "/root"
                    let fullPath = (sub["path"] as! String)
                    let end = fullPath.index(fullPath.endIndex, offsetBy: -1)
                    driveFile.parentPath = String(fullPath[..<end])
                    driveFile.pathName = "items/\(ID)"
                    if driveFile.parentId == nil {
                        driveFile.pathName = "/"
                    }
                    result(driveFile, nil)
                })
        })
    }

    override func mkdirs(pathname: String) throws {
        // TODO
    }
}
