import Foundation
import PromiseKit

@objc(HiveIpfsClient)
internal class HiveIpfsClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private init(param: HiveIpfsParameter){
        super.init(DriveType.hiveIpfs)
        super._clientId = "TOO"
    }

    @objc(createInstance:)
    private static func createInstance(param: HiveIpfsParameter) {
        if clientInstance == nil {
            let client: HiveIpfsClient = HiveIpfsClient(param: param)
            clientInstance = client as HiveClientHandle;
        }
    }

    static func sharedInstance() -> HiveClientHandle? {
        return clientInstance
    }

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
