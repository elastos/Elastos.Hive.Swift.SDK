import Foundation

@inline(__always) private func TAG() -> String { return "OneDrive" }

@objc(OneDriveClient)
internal class OneDriveClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?
    var authHeperHandle: OneDriveAuthHelper
    var driveId: String?
    public static var oneDrive: OneDrive?

    private init(_ param: OneDriveParameters) {
        authHeperHandle = OneDriveAuthHelper(param.clientId!, param.scopes!, param.redirectUrl!)
    }

    public static func createInstance(_ param: OneDriveParameters) {
        if clientInstance == nil {
            let client: OneDriveClient = OneDriveClient(param)
            clientInstance = client as HiveClientHandle
            oneDrive = OneDrive(client)
        }
    }

    public static func sharedInstance() -> HiveClientHandle? {
        return clientInstance
    }

    override func driveType() -> DriveType {
        return .oneDrive
    }

    override func login() -> CallbackFuture<Bool> {
        return authHeperHandle.login()
    }

    override func logout() -> CallbackFuture<Bool>? {
        // TODO
        return nil
    }

    override func defaultDriveHandle() -> HiveDriveHandle? {
        // TODO
        return OneDriveClient.oneDrive
    }

    /*
    override func login(withResult: @escaping (HiveResultHandler)) {
        authHeperHandle.login { (re, error) in
            try? self.getClientInfo()
            withResult(re, error)
        }
    }


    override func logout(withResult: @escaping (HiveResultHandler)) {
        authHeperHandle.logout { (re, error) in
            withResult(re, error)
        }
    }

    private func getClientInfo() throws {
        // TODO
    }

    override func GetDefaultDrive() throws -> HiveDriveHandle? {
        let drive: OneDrive = OneDrive(self)
        return drive as HiveDriveHandle
    }
*/

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
}
