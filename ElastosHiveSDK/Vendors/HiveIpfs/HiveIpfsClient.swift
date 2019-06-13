import Foundation
import PromiseKit
import Alamofire

@objc(HiveIpfsClient)
internal class HiveIpfsClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private init(param: HiveIpfsParameter){
        super.init(.hiveIpfs)
        self.authHelper = HiveIpfsAuthHelper(param)
    }

    public static func createInstance(_ param: HiveIpfsParameter) {
        if clientInstance == nil {
            let client: HiveIpfsClient = HiveIpfsClient(param: param)
            clientInstance = client as HiveClientHandle;
        }
    }

    static func sharedInstance() -> HiveClientHandle? {
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
        // TODO
        return false
    }

    override func lastUpdatedInfo() -> HivePromise<HiveClientInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>) -> HivePromise<HiveClientInfo> {
        let error = HiveError.failue(des: "TODO")
        return HivePromise<HiveClientInfo>(error: error)
    }

    override func defaultDriveHandle() -> HivePromise<HiveDriveHandle> {
        return defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>())
    }

    override func defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>) -> HivePromise<HiveDriveHandle> {
        if HiveIpfsDrive.hiveDriveInstance != nil {
            let promise = HivePromise<HiveDriveHandle>{ resolver in
                let hdHandle = HiveIpfsDrive.sharedInstance()
                handleBy.didSucceed(hdHandle)
                resolver.fulfill(hdHandle)
            }
            return promise
        }
        let promise = HivePromise<HiveDriveHandle>{ resolver in
            _ = self.authHelper?.checkExpired().done({ (success) in

                let url = HiveIpfsURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_LS.rawValue
                let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
                let param = ["uid": uid, "path": "/"]
                Alamofire.request(url,
                                  method: .post,
                                  parameters: param,
                                  encoding: URLEncoding.queryString, headers: nil)
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else{
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        let driveInfo = HiveDriveInfo(uid)
                        let driveHandle = HiveIpfsDrive(driveInfo, self.authHelper!)
                        driveHandle.lastInfo = driveInfo
                        resolver.fulfill(driveHandle)
                        handleBy.didSucceed(driveHandle)
                    })
            })
        }
        return promise
    }
}
