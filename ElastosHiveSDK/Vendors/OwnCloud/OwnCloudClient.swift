import Foundation

@objc(OwnCloudClient)
internal class OwnCloudClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private var authHelperHandle: AuthHelper?

    private init(_ param: OwnCloudParameters) {
    }

    @objc(createInstance:)
    private static func createInstance(param: OwnCloudParameters) {
        if clientInstance == nil {
            let client: OwnCloudClient = OwnCloudClient(param)
            clientInstance = client as HiveClientHandle
        }
    }

    static func sharedInstance() -> HiveClientHandle? {
        return clientInstance
    }

    override func driveType() -> DriveType {
        // TODO
        return .ownCloud
    }

    override func login() -> CallbackFuture<Bool>? {
        return nil
    }

    override func logout() -> CallbackFuture<Bool>? {
        // TODO
        return nil
    }

//    override func login(withResult: @escaping (HiveResultHandler)) {
//        // TODO
//    }
//
//    override func logout(withResult: @escaping (HiveResultHandler)) {
//        // TODO
//    }
}
