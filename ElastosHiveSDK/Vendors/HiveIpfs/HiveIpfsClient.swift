import Foundation
import PromiseKit

@objc(HiveIpfsClient)
internal class HiveIpfsClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private init(param: HiveIpfsParameter){
        super.init(DriveType.hiveIpfs)

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

    override func lastUpdatedInfo() -> HivePromise<HiveClientInfo>? {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>) -> HivePromise<HiveClientInfo>? {
        let error = HiveError.failue(des: "TODO")
        return HivePromise<HiveClientInfo>(error: error)
    }

    override func defaultDriveHandle() -> HivePromise<HiveDriveHandle>? {
        return defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>())
    }

    override func defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>) -> HivePromise<HiveDriveHandle>? {
        let error = HiveError.failue(des: "TODO")
        return HivePromise<HiveDriveHandle>(error: error)
    }
}
