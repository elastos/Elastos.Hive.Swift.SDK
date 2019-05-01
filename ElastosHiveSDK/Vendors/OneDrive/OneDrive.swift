import Foundation
import Unirest

@inline(__always) private func TAG() -> String { return "OneDrive" }

internal class OneDrive: HiveDriveHandle {
    private static var oneDriveInstance: OneDrive?
    var authHeperHandle: OneDriveAuthHelper
    var driveId: String?

    private init(_ param: OneDriveParameters) {
        authHeperHandle = OneDriveAuthHelper(param.clientId!, param.scopes!, param.redirectUrl!)
    }

    public static func createInstance(_ param: OneDriveParameters) {
        if oneDriveInstance == nil {
            let drive: OneDrive = OneDrive(param)
            oneDriveInstance = drive as OneDrive
        }
    }

    public static func sharedInstance() -> HiveDriveHandle? {
        return oneDriveInstance
    }

    override func driveType() -> DriveType {
        return .oneDrive
    }

    override func login(withResult: @escaping (HiveResultHandler)) {
        authHeperHandle.login { (re, error) in
            try? self.validateDrive()
            withResult(re, error)
        }
    }
    override func logout(withResult: @escaping (HiveResultHandler)) {
        authHeperHandle.logout { (re, error) in
            withResult(re, error)
        }
    }

    override func rootDirectoryHandle(withResult resultHandler: @escaping HiveFileObjectCreationResponseHandler) throws {
        if authHeperHandle.authInfo == nil {
            Log.e(TAG(), "Have to login first.")
            resultHandler(nil, .failue(des: "Please login first"))
            return
        }

        authHeperHandle.checkExpired { (error) in
            guard error == nil else {
                resultHandler(nil, error)
                return
            }

            let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
            UNIRest.get({ (request) in
                request?.url = ONEDRIVE_RESTFUL_URL + ONEDRIVE_ROOTDIR
                request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
            })?.asJsonAsync({ (response, error) in
                if response?.code != 200 {
                    resultHandler(nil, .jsonFailue(des: (response?.body.jsonObject())!))
                    return
                }

                let jsonData = response?.body.jsonObject() as? Dictionary<String, Any>
                guard jsonData != nil && !jsonData!.isEmpty else {
                    resultHandler(nil, nil)
                    return
                }
                let driveFile: OneDriveFile = OneDriveFile()
                driveFile.drive = self
                let folder = response?.body.jsonObject()["folder"]
                if folder != nil {
                    driveFile.isDirectory = true
                    driveFile.isFile = false
                }
                driveFile.createdDateTime = (jsonData!["createdDateTime"] as? String)
                driveFile.lastModifiedDateTime = (jsonData!["lastModifiedDateTime"] as! String)
                driveFile.fileSystemInfo = (jsonData!["fileSystemInfo"] as? Dictionary)
                driveFile.id = (jsonData!["id"] as? String)
                driveFile.rootPath = "/root"
                let sub = jsonData!["parentReference"] as? NSDictionary
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
                driveFile.pathName =  "/"
                driveFile.oneDrive = self
                resultHandler(driveFile, nil)
            })
        }
    }

    override func createDirectory(atPath: String, withResult: @escaping HiveFileObjectCreationResponseHandler) throws {
        if authHeperHandle.authInfo == nil {
            print("Please login first")
            withResult(nil, .failue(des: "Please login first"))
            return
        }
        authHeperHandle.checkExpired { (error) in
            if (error != nil) {
                withResult(nil, error)
                return
            }
            let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
            let params: Dictionary<String, Any> = ["name": "New Folder",
                                                   "folder": [: ],
                                                   "@microsoft.graph.conflictBehavior": "rename"]
            UNIRest.postEntity { (request) in
                request?.url = "\(ONEDRIVE_RESTFUL_URL)/items/\(atPath)/children"
                request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                request?.body = try? JSONSerialization.data(withJSONObject: params)
                }?.asJsonAsync({ (response, error) in
                    if response?.code != 201 {
                        withResult(nil, .jsonFailue(des: (response?.body.jsonObject())!))
                        return
                    }
                    // TODO  judje
                    let jsonData = response?.body.jsonObject() as? Dictionary<String, Any>
                    if jsonData == nil || jsonData!.isEmpty {
                        withResult(nil, nil)
                    }
                    let driveFile: OneDriveFile = OneDriveFile()
                    driveFile.drive = self
                    driveFile.oneDrive = self
                    driveFile.pathName =  atPath
                    let folder = jsonData!["folder"]
                    if folder != nil {
                        driveFile.isDirectory = true
                        driveFile.isFile = false
                    }
                    driveFile.createdDateTime = (jsonData!["createdDateTime"] as? String)
                    driveFile.lastModifiedDateTime = (jsonData!["lastModifiedDateTime"] as? String)
                    driveFile.fileSystemInfo = (jsonData!["fileSystemInfo"] as? Dictionary)
                    driveFile.id = (jsonData!["id"] as? String)
                    driveFile.rootPath = ONEDRIVE_RESTFUL_URL + "/root"
                    let sub = jsonData!["parentReference"] as? NSDictionary
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
                    withResult(driveFile, nil)
                })
        }
    }

    override func getFileHandle(atPath: String, withResult resultHandler: @escaping HiveFileObjectCreationResponseHandler) throws {
        if authHeperHandle.authInfo == nil {
            print("Please login first")
            resultHandler(nil, .failue(des: "Please login first"))
            return
        }
        authHeperHandle.checkExpired { (error) in
            if (error != nil) {
                resultHandler(nil, error)
                return
            }
            let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
            var url = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):/\(atPath)"
            if atPath == "/" {
                url = ONEDRIVE_RESTFUL_URL + ONEDRIVE_ROOTDIR
            }
            UNIRest.get({ (request) in
                request?.url = url
                request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
            })?.asJsonAsync({ (response, error) in
                if response?.code != 200 {
                    resultHandler(nil, .jsonFailue(des: (response?.body.jsonObject())!))
                    return
                }
                // todo jude
                //            let id = response?.body.jsonObject()["id"]
                //            if id == nil {
                //                resultHandler(nil, .failue(des: "pathname is invalid path"))
                //            }
                let jsonData = response?.body.jsonObject() as? Dictionary<String, Any>
                if jsonData == nil || jsonData!.isEmpty {
                    resultHandler(nil, nil)
                }
                let driveFile: OneDriveFile = OneDriveFile()
                driveFile.drive = self
                driveFile.oneDrive = self
                driveFile.pathName =  atPath
                let folder = jsonData!["folder"]
                if folder != nil {
                    driveFile.isDirectory = true
                    driveFile.isFile = false
                }
                driveFile.createdDateTime = (jsonData!["createdDateTime"] as? String)
                driveFile.lastModifiedDateTime = (jsonData!["lastModifiedDateTime"] as? String)
                driveFile.fileSystemInfo = (jsonData!["fileSystemInfo"] as? Dictionary)
                driveFile.id = (jsonData!["id"] as? String)
                driveFile.rootPath = ONEDRIVE_RESTFUL_URL + ONEDRIVE_ROOTDIR
                let sub = jsonData!["parentReference"] as? NSDictionary
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
                resultHandler(driveFile, nil)
            })
        }
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
}
