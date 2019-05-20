import Foundation
import PromiseKit

@objc(DropboxClient)
internal class DropboxClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private init(_ param: DriveParameter) {
        super.init(DriveType.dropBox)
        self._clientId = "TODO"
    }

    @objc(createInstance:)
    public static func createInstance(param: DriveParameter){
        if clientInstance == nil {
            let client: DropboxClient = DropboxClient(param)
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
