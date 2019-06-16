import Foundation
import PromiseKit
import Alamofire

@inline(__always) private func TAG() -> String { return "IPFSClient" }

@objc(IPFSClient)
internal class IPFSClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private init(param: IPFSParameter){
        super.init(.hiveIpfs)
        self.authHelper = IPFSAuthHelper(param)
    }

    public static func createInstance(_ param: IPFSParameter) {
        if clientInstance == nil {
            let client: IPFSClient = IPFSClient(param: param)
            clientInstance = client as HiveClientHandle
            Log.d(TAG(), "createInstance succeed")
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
        let promise = HivePromise<HiveClientInfo> { resolver in
            _ = self.authHelper!.checkExpired().done({ (success) in

                let url = IPFSURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
                let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
                let params = ["uid": uid, "path": "/"]
                Alamofire.request(url,
                                  method: .post,
                                  parameters: params,
                                  encoding: URLEncoding.queryString,
                                  headers: nil)
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else {
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "lastUpdatedInfo falied: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        Log.d(TAG(), "lastUpdatedInfo succeed")
                        let clientId = "TODO"
                        let clientInfo = HiveClientInfo(clientId)
                        self.lastInfo = clientInfo
                        handleBy.didSucceed(clientInfo)
                        resolver.fulfill(clientInfo)
                    })
            }).catch({ (error) in
                let error = HiveError.failue(des: error.localizedDescription)
                Log.e(TAG(), "lastUpdatedInfo falied: %s", error.localizedDescription)
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
        if IPFSDrive.hiveDriveInstance != nil {
            let promise = HivePromise<HiveDriveHandle>{ resolver in
                let hdHandle = IPFSDrive.sharedInstance()
                handleBy.didSucceed(hdHandle)
                resolver.fulfill(hdHandle)
            }
            return promise
        }
        let promise = HivePromise<HiveDriveHandle>{ resolver in
            _ = self.authHelper?.checkExpired().done({ (success) in

                let url = IPFSURL.IPFS_NODE_API_BASE + HIVE_SUB_Url.IPFS_FILES_LS.rawValue
                let uid = HelperMethods.getKeychain(KEYCHAIN_IPFS_UID, .IPFSACCOUNT) ?? ""
                let param = ["uid": uid, "path": "/"]
                Alamofire.request(url,
                                  method: .post,
                                  parameters: param,
                                  encoding: URLEncoding.queryString, headers: nil)
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else{
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "defaultDriveHandle falied: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        Log.d(TAG(), "defaultDriveHandle succeed")
                        let driveInfo = HiveDriveInfo(uid)
                        let driveHandle = IPFSDrive(driveInfo, self.authHelper!)
                        driveHandle.lastInfo = driveInfo
                        resolver.fulfill(driveHandle)
                        handleBy.didSucceed(driveHandle)
                    })
            }).catch({ (error) in
                let error = HiveError.failue(des: error.localizedDescription)
                Log.e(TAG(), "defaultDriveHandle falied: %s", error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return promise
    }
}
