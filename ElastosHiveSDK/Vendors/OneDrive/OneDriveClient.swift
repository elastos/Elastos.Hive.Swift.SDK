import Foundation
import PromiseKit
import Alamofire

@inline(__always) private func TAG() -> String { return "OneDriveClient" }

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
            Log.d(TAG(), "OneDrive Client singleton instance created")
        }
    }

    public static func sharedInstance() -> HiveClientHandle? {
        return clientInstance
    }

    override func login(_ authenticator: Authenticator) throws {
        let promise = self.authHelper?.loginAsync(authenticator)
        do {
             _ = try (promise?.wait())!
             _ = defaultDriveHandle() // TODO:
        } catch  {
            throw error
        }
    }

    override func logout() throws {
        let promise = self.authHelper?.logoutAsync()
        do {
            _ = try (promise?.wait())!
        } catch {
            throw error;
        }
    }

    override func lastUpdatedInfo() -> HivePromise<HiveClientInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>) -> HivePromise<HiveClientInfo> {
        let promise = HivePromise<HiveClientInfo> { resolver in
            let login = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
            guard login != "" else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                handleBy.runError(error)
                return
            }
            _ = self.authHelper!.checkExpired().done { result in
                Alamofire.request(OneDriveURL.API, method: .get,
                                  parameters: nil,
                                    encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers())
                    .responseJSON { dataResponse in
                        guard dataResponse.response?.statusCode != 401 else {
                            let error = HiveError.failue(des: TOKEN_INVALID)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        guard dataResponse.response?.statusCode == 200 else {
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "Acquire last client information failed: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        let jsonData = JSON(dataResponse.result.value as Any)
                        let owner = JSON(jsonData["owner"])
                        let user = JSON(owner["user"])
                        let dic = [
                            HiveClientInfo.userId: user["id"].stringValue,
                            HiveClientInfo.name: "",
                            HiveClientInfo.email: user["email"].stringValue,
                            HiveClientInfo.phoneNo: user["phone"].stringValue,
                            HiveClientInfo.region: user["region"].stringValue
                        ]
                        let clientInfo = HiveClientInfo(dic)
                        handleBy.didSucceed(clientInfo)
                        resolver.fulfill(clientInfo)

                        Log.d(TAG(), "Acquired client information from remote drive: %s", clientInfo.debugDescription);
                }
            }.catch { err in
                let error = HiveError.failue(des: err.localizedDescription)
                Log.e(TAG(), "Acquiring client information from remote server failed: %s", error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            }
        }
        return promise
    }

    override func defaultDriveHandle() -> HivePromise<HiveDriveHandle> {
        return defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>())
    }

    override func defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>) -> HivePromise<HiveDriveHandle> {
        let promise = HivePromise<HiveDriveHandle> { resolver in
            let login = HelperMethods.getKeychain(KEYCHAIN_KEY.ACCESS_TOKEN.rawValue, .ONEDRIVEACOUNT) ?? ""
            guard login != "" else {
                Log.d(TAG(), "Please login first")
                let error = HiveError.failue(des: "Please login first")
                resolver.reject(error)
                handleBy.runError(error)
                return
            }
            guard OneDriveDrive.oneDriveInstance == nil else {
                let handle = OneDriveDrive.sharedInstance()
                handleBy.didSucceed(handle)
                resolver.fulfill(handle)
                return
            }

            _ = self.authHelper!.checkExpired().done { result in
                Alamofire.request(OneDriveURL.API + "/root", method: .get,
                                  parameters: nil,
                                    encoding: JSONEncoding.default,
                                     headers: OneDriveHttpHeader.headers())
                    .responseJSON { dataResponse in
                        guard dataResponse.response?.statusCode != 401 else {
                            let error = HiveError.failue(des: TOKEN_INVALID)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        guard dataResponse.response?.statusCode == 200 else{
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "Acquiring default drive handle failed: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        let jsonData = JSON(dataResponse.result.value as Any)
                        let driveId = jsonData["id"].stringValue
                        let dic = [HiveDriveInfo.driveId: driveId]
                        let driveInfo = HiveDriveInfo(dic)
                        let dirHandle = OneDriveDrive(driveInfo, self.authHelper!)
                        dirHandle.lastInfo = driveInfo
                        resolver.fulfill(dirHandle)
                }
            }.catch { err in
                let error = HiveError.failue(des: err.localizedDescription)
                Log.e(TAG(), "Acquiring default drive instance failed: %s", error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            }
        }
        return promise
    }
}
