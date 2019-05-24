import Foundation
import PromiseKit

@inline(__always) private func TAG() -> String { return "OneDrive" }

@objc(OneDriveClient)
internal class OneDriveClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private init(_ param: OneDriveParameter) {
        super.init(DriveType.oneDrive)
        self._clientId = "TODO"
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
        return self.authHelper?.login(authenticator)
    }

    override func logout() -> Bool? {
        return self.authHelper?.logout()
    }
/*
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
*/
    override func lastUpdatedInfo() -> Promise<HiveClientInfo>? {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>) -> Promise<HiveClientInfo>? {
        let error = HiveError.failue(des: "TODO")
        return Promise<HiveClientInfo>(error: error)
    }

    override func defaultDriveHandle() -> Promise<HiveDriveHandle>? {
        return defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>())
    }

    override func defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>) -> Promise<HiveDriveHandle>? {
        let error = HiveError.failue(des: "TODO")
        return Promise<HiveDriveHandle>(error: error)
    }
}
