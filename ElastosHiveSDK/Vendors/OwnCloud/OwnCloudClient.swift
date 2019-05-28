import Foundation
import PromiseKit

@objc(OwnCloudClient)
internal class OwnCloudClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private init(_ param: OwnCloudParameter) {
        super.init(DriveType.ownCloud)

    }

    @objc(createInstance:)
    private static func createInstance(param: OwnCloudParameter) {
        if clientInstance == nil {
            let client: OwnCloudClient = OwnCloudClient(param)
            clientInstance = client as HiveClientHandle
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
