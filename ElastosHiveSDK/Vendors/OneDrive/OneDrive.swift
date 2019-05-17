import Foundation
import Unirest

@inline(__always) private func TAG() -> String { return "OneDrive" }

internal class OneDrive: HiveDriveHandle {
    var client: OneDriveClient
    var authHelperHandle: OneDriveAuthHelper
    var driveId: String?

    init(_ client: OneDriveClient) {
        self.client = client
        self.authHelperHandle = client.authHeperHandle
    }

    override func driveType() -> DriveType {
        return .oneDrive
    }

    override func driveInfo() -> HiveDriveInfo? {
        // TODO
        return nil
    }

    override func rootDirectoryHandle() -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        let future = CallbackFuture<HiveResult<HiveDirectoryHandle>> { resolver in
            if authHelperHandle.authInfo == nil {
                Log.e(TAG(), "Have to login first.")
                resolver.reject(HiveError.failue(des: "Please login first"))
                return
            }
            _ = authHelperHandle.checkExpired()?.done({ (result) in
                if result {
                    let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
                    UNIRest.get({ (request) in
                        request?.url = ONEDRIVE_RESTFUL_URL + ONEDRIVE_ROOTDIR
                        request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                    })?.asJsonAsync({ (response, error) in
                        if response?.code != 200 {
                            resolver.reject(HiveError.jsonFailue(des: response?.body.jsonObject()))
                            return
                        }
                        let jsonData = response?.body.jsonObject() as? Dictionary<String, Any>
                        guard jsonData != nil && !jsonData!.isEmpty else {
                            resolver.reject(HiveError.systemError(error: error, jsonDes: jsonData))
                            return
                        }
                        let hiveDirectoryHandel = self.handleResult("/", jsonData!)
                        resolver.fulfill(HiveResult(handle: hiveDirectoryHandel))
                    })
                }
            })
        }
        return future
    }

    override func createDirectory(atPath: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        let future = CallbackFuture<HiveResult<HiveDirectoryHandle>> { resolver in

            if authHelperHandle.authInfo == nil {
                print("Please login first")
                resolver.reject(HiveError.failue(des: "error"))
                return
            }
            _ = authHelperHandle.checkExpired()!.done({ (result) in
                if result {
                    let components: [String] = (atPath.components(separatedBy: "/"))
                    let name = components.last
                    let index = atPath.range(of: "/", options: .backwards)?.lowerBound
                    let path_0 = index.map(atPath.prefix(upTo:)) ?? ""
                    let path = path_0.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
                    let params: Dictionary<String, Any> = ["name": name as Any,
                                                           "folder": [: ],
                                                           "@microsoft.graph.conflictBehavior": "rename"]
                    UNIRest.postEntity { (request) in
                        request?.url = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):/\(path):/children"
                        request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                        request?.body = try? JSONSerialization.data(withJSONObject: params)
                        }?.asJsonAsync({ (response, error) in
                            if response?.code != 201 {
                                resolver.reject(HiveError.systemError(error: error, jsonDes: response?.body.jsonObject()))
                                return
                            }
                            let jsonData = response?.body.jsonObject() as? Dictionary<String, Any>
                            if jsonData == nil || jsonData!.isEmpty {
                                resolver.reject(HiveError.systemError(error: error, jsonDes: nil))
                            }
                            let hiveDirectoryHandle = self.handleResult(atPath, jsonData!)
                            resolver.fulfill(HiveResult(handle: hiveDirectoryHandle))
                        })
                }
            })
        }
        return future
    }
    
    override func createFile(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        let fulture = CallbackFuture<HiveResult<HiveFileHandle>>{ resolver in
            if authHelperHandle.authInfo == nil {
                resolver.reject(HiveError.failue(des: "Please login first"))
                return
            }
            _ = self.authHelperHandle.checkExpired()?.done({ (result) in
                if result {
                    let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
                    UNIRest.putEntity { (request) in
                        request?.url = "\(ONEDRIVE_RESTFUL_URL)\(ONEDRIVE_ROOTDIR):/\(atPath):/content"
                        request?.headers = ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
                        }?.asJsonAsync({ (response, error) in
                            if response?.code != 201 {
                                resolver.reject(HiveError.jsonFailue(des: response?.body.jsonObject()))
                                return
                            }
                            let jsonData = response?.body.jsonObject() as? Dictionary<String, Any>
                            if jsonData == nil || jsonData!.isEmpty {
                                resolver.reject(HiveError.systemError(error: error, jsonDes: response?.body.jsonObject()))
                            }
                            let hiveDirectoryHandle = self.handleResult(atPath, jsonData!)
                            resolver.fulfill(HiveResult(handle: hiveDirectoryHandle.hiveFile!))
                        })
                }
            })
        }
        return fulture
    }

    override func fileHandle(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        // TODO
        return nil
    }

    override func directoryHandle(atPath: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {

        let fulture = CallbackFuture<HiveResult<HiveDirectoryHandle>>{ resolver in
            if authHelperHandle.authInfo == nil {
                resolver.reject(HiveError.failue(des: "Please login first"))
                return
            }
            _ = self.authHelperHandle.checkExpired()?.done({ (result) in
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
                        resolver.reject(HiveError.jsonFailue(des: response?.body.jsonObject()))
                        return
                    }
                    let jsonData = response?.body.jsonObject() as? Dictionary<String, Any>
                    if jsonData == nil || jsonData!.isEmpty {
                        resolver.reject(HiveError.systemError(error: error, jsonDes: jsonData))
                    }
                    let hiveDrictoryHandel = self.handleResult(atPath, jsonData!)
                    resolver.fulfill(HiveResult(handle: hiveDrictoryHandel))
                })
            })
        }
        return fulture
    }

    internal func handleResult(_ atPath: String, _ jsonData: Dictionary<String, Any>) -> HiveDirectoryHandle {

        let hiveDirectoryHandle = HiveDirectoryHandle()
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
        hiveDirectoryHandle.hiveFile = driveFile
        return hiveDirectoryHandle
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
