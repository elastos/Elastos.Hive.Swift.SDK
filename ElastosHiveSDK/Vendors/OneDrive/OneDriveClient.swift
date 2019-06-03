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

    override func login(_ authenticator: Authenticator) -> Bool {

        var result = false
        let promise =  self.authHelper?.loginAsync(authenticator)
        do {
            result = try (promise?.wait())!
             _ = defaultDriveHandle()
        } catch  {
            result = false
        }
        return result
    }

    override func logout() -> Bool {
        var result = false
        let promise = self.authHelper?.logoutAsync()
        do {
            result = try (promise?.wait())!
        } catch {
            result = false
        }
        return result
    }

    override func lastUpdatedInfo() -> HivePromise<HiveClientInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>) -> HivePromise<HiveClientInfo> {
        let promise = HivePromise<HiveClientInfo> { resolver in
            _ = self.authHelper!.checkExpired().done({ (result) in

                Alamofire.request(ONEDRIVE_RESTFUL_URL,
                                  method: .get,
                                  parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else {
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        let jsonData = JSON(dataResponse.result.value as Any)
                        let owner = JSON(jsonData["owner"])
                        let user = JSON(owner["user"])
                        let clientId = user["id"].stringValue
                        let clientInfo = HiveClientInfo(clientId)
                        clientInfo.installValue(user)
                        handleBy.didSucceed(clientInfo)
                        resolver.fulfill(clientInfo)
                }
            }).catch({ (err) in
                let error = HiveError.failue(des: err.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return promise
    }

    override func defaultDriveHandle() -> HivePromise<HiveDriveHandle> {
        return defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>())
    }

    override func defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>) -> HivePromise<HiveDriveHandle> {
        if OneDriveDrive.oneDriveInstance != nil {
            let promise = HivePromise<HiveDriveHandle>{ resolver in
                let hdHandle = OneDriveDrive.sharedInstance()
                handleBy.didSucceed(hdHandle)
                resolver.fulfill(hdHandle)
            }
            return promise
        }
        let promise = HivePromise<HiveDriveHandle> { resolver in
            _ = self.authHelper!.checkExpired().done({ (result) in
                Alamofire.request(OneDriveURL.API + "/root",
                                  method: .get,
                                  parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else{
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        let jsonData = JSON(dataResponse.result.value as Any)
                        let driveId = jsonData["id"].stringValue
                        let driveInfo = HiveDriveInfo(driveId)
                        driveInfo.installValue(jsonData)
                        let dirHandle = OneDriveDrive(driveInfo, self.authHelper!)
                        dirHandle.lastInfo = driveInfo
                        resolver.fulfill(dirHandle)
                    })
            }).catch({ (err) in
                let error = HiveError.failue(des: err.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return promise
    }

}
