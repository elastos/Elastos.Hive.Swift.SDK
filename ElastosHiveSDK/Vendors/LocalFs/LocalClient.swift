import Foundation
import PromiseKit

@objc(LocalClient)
internal class LocalClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private init(_ param: LocalParameter) {
        super.init(DriveType.local)
        super._clientId = "TODO"
    }

    @objc(createInstance:)
    private static func createInstance(param: DriveParameter) {
        if clientInstance == nil {
            let client: LocalClient = LocalClient(param)
            clientInstance = client as HiveClientHandle
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
