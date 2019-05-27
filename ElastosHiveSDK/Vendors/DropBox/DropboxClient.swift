import Foundation
import PromiseKit

@objc(DropboxClient)
internal class DropboxClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private init(_ param: DriveParameter) {
        super.init(DriveType.dropBox)
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
