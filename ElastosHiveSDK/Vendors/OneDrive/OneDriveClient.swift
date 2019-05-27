import Foundation
import PromiseKit
import Alamofire

@inline(__always) private func TAG() -> String { return "OneDrive" }

@objc(OneDriveClient)
internal class OneDriveClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private init(_ param: OneDriveParameter) {
        super.init(DriveType.oneDrive)
        self.authHelper = OneDriveAuthHelper(param.getAuthEntry())
    }

    public static func createInstance(_ param: OneDriveParameter) {
        if clientInstance == nil {
            let client: OneDriveClient = OneDriveClient(param)
            clientInstance = client as HiveClientHandle
        }
    }

    public static func sharedInstance() -> HiveClientHandle? {
        return clientInstance
    }
    override func login(_ authenticator: Authenticator) -> Bool? {
        let result = self.authHelper?.login(authenticator)
       _ = defaultDriveHandle()
        return result
    }

    override func logout() -> Bool? {
        return self.authHelper?.logout()
    }

    override func lastUpdatedInfo() -> HivePromise<HiveClientInfo>? {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>) -> HivePromise<HiveClientInfo>? {
        let promise = HivePromise<HiveClientInfo> { resolver in
            Alamofire.request(ONEDRIVE_RESTFUL_URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: (OneDriveHttpHeader.headers())).responseJSON { (dataResponse) in
                print(dataResponse)
                dataResponse.result.ifSuccess {
                    guard dataResponse.response?.statusCode == 200 else {
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
                    // driveclientInfo
                    let owner = jsonData!["owner"] as? Dictionary<String, Any> ?? [: ]
                    let user = owner["user"] as? Dictionary<String, Any> ?? [: ]
                    self.handleId = user["id"] as? String ?? ""
                    let clientInfo = HiveClientInfo()
                    clientInfo.displayName = user["displayName"] as? String ?? ""
                    clientInfo.userId = user["id"] as? String ?? ""
                    handleBy.didSucceed(clientInfo)
                    resolver.fulfill(clientInfo)
                }
                dataResponse.result.ifFailure {
                    let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                    resolver.reject(error)
                    handleBy.runError(error)
                }
            }
        }
        return promise
    }

    override func defaultDriveHandle() -> HivePromise<HiveDriveHandle>? {
        return defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>())
    }

    override func defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>) -> HivePromise<HiveDriveHandle>? {
        var driveInfo_1 = [String: Any]()
        var driveInfo_2 = [String: Any]()
        var driveId = ""
        if OneDriveDrive.oneDriveInstance != nil {
            let promise = HivePromise<HiveDriveHandle>{ resolver in
                let hdHandle = OneDriveDrive.sharedInstance()
                handleBy.didSucceed(hdHandle)
                resolver.fulfill(hdHandle)
            }
            return promise
        }
        let promise = HivePromise<HiveDriveHandle> { resolver in
            let group = DispatchGroup()
            let queue = DispatchQueue.main

            group.enter()
                self.driveInfo_1().done({ (jsonData) in
                    driveInfo_1 = jsonData ?? [: ]
                    group.leave()
                }).catch({ (error) in
                    driveInfo_1 = [: ]
                    let error = HiveError.systemError(error: error, jsonDes: nil)
                    resolver.reject(error)
                    handleBy.runError(error)
                    group.leave()
                })
            group.enter()
                self.driveInfo_2().done({ (jsonData) in
                    driveInfo_2 = jsonData ?? [: ]
                    group.leave()
                }).catch({ (error) in
                    let error = HiveError.systemError(error: error, jsonDes: nil)
                    resolver.reject(error)
                    handleBy.runError(error)
                    driveInfo_2 = [: ]
                    group.leave()
                })
            group.notify(queue: queue, execute: {
                let driveInfo = HiveDriveInfo()
                if !driveInfo_1.isEmpty {
                    let quota = driveInfo_1["quota"] as? Dictionary<String, Any> ?? [: ]
                    driveInfo.capacity = quota["total"] as? String ?? ""
                    driveInfo.used = quota["used"] as? String ?? ""
                    driveInfo.remaining = quota["remaining"] as? String ?? ""
                    driveInfo.deleted = quota["deleted"] as? String ?? ""
                    driveId = driveInfo_1["id"] as? String ?? ""
                    let stat = driveInfo_1["state"] as? String ?? ""
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
                }
                if driveInfo_1.isEmpty || driveInfo_2.isEmpty {
                    let error = HiveError.failue(des: "result is nil")
                    handleBy.runError(error)
                    resolver.reject(error)
                    return
                }
                if !driveInfo_2.isEmpty {
                    print(driveInfo_2)
                    driveInfo.lastModifiedDateTime = driveInfo_2["lastModifiedDateTime"] as? String ?? ""
                    let folder = driveInfo_2["folder"] as? Dictionary<String, Any> ?? [: ]
                    driveInfo.fileCount = folder["childCount"] as? String ?? ""
                    driveInfo.ddescription = ""
                }
                // driveHandle
                OneDriveDrive.createInstance(driveInfo, self.authHelper!)
                let onedriveHandle = OneDriveDrive.sharedInstance()
                onedriveHandle.handleId = driveId
                onedriveHandle.lastInfo = driveInfo

                // driveclientInfo
                let owner = driveInfo_1["owner"] as? Dictionary<String, Any> ?? [: ]
                let user = owner["user"] as? Dictionary<String, Any> ?? [: ]
                self.handleId = user["id"] as? String ?? ""
                let clientInfo = HiveClientInfo()
                clientInfo.displayName = user["displayName"] as? String ?? ""
                resolver.fulfill(onedriveHandle)
            })
        }
        return promise
    }

    private func driveInfo_1() -> HivePromise<Dictionary<String, Any>?> {
        let promise = HivePromise<Dictionary<String, Any>?> { resolver in
            Alamofire.request(ONEDRIVE_RESTFUL_URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: (OneDriveHttpHeader.headers())).responseJSON { (dataResponse) in
                print(dataResponse)
                dataResponse.result.ifSuccess {
                    guard dataResponse.response?.statusCode == 200 else {
                        resolver.reject(HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>))
                        return
                    }
                    let jsonData = dataResponse.result.value as? Dictionary<String, Any>
                    resolver.fulfill(jsonData)
                }
                dataResponse.result.ifFailure {
                    resolver.reject(HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>))
                }
            }
        }
        return promise
    }

    private func driveInfo_2() -> HivePromise<Dictionary<String, Any>?> {
        let future = HivePromise<Dictionary<String, Any>?> { resolver in
            Alamofire.request(OneDriveURL.API + "/root", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: (OneDriveHttpHeader.headers())).responseJSON(completionHandler: { (dataResponse) in
                dataResponse.result.ifSuccess {
                    guard dataResponse.response?.statusCode == 200 else{
                        let error = HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>)
                        resolver.reject(error)
                        return
                    }
                    let jsonData = dataResponse.result.value as? Dictionary<String, Any>
                    guard jsonData != nil else {
                        let error = HiveError.failue(des: "result is nil")
                        resolver.reject(error)
                        return
                    }
                    resolver.fulfill(jsonData)
                }
                dataResponse.result.ifFailure {
                    resolver.reject(HiveError.jsonFailue(des: dataResponse.result.value as? Dictionary<AnyHashable, Any>))
                }
            })
        }
        return future
    }
}
