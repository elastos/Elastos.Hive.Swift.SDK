import Foundation
import PromiseKit

@objc(NativeClient)
internal class NativeClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private init(_ param: NativeParameter) {
        super.init(.nativeStorage)
    }

    @objc(createInstance:)
    private static func createInstance(param: DriveParameter) {
        if clientInstance == nil {
            let client: NativeClient = NativeClient(param as! NativeParameter)
            clientInstance = client as HiveClientHandle
        }
    }

    static func sharedInstance() -> HiveClientHandle? {
        return clientInstance
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
        let error = HiveError.failue(des: "TODO")
        return HivePromise<HiveDriveHandle>(error: error)
    }
}
