import Foundation

@objc(HiveIpfsClient)
internal class HiveIpfsClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private var authHelperHandle: AuthHelper?

    private init(param: HiveIpfsParameters){
        // TODO
    }

    @objc(createInstance:)
    private static func createInstance(param: HiveIpfsParameters) {
        if clientInstance == nil {
            let client: HiveIpfsClient = HiveIpfsClient(param: param)
            clientInstance = client as HiveClientHandle;
        }
    }

    static func sharedInstance() -> HiveClientHandle? {
        return clientInstance
    }

    override func driveType() -> DriveType {
        return .ownCloud
    }

    override func login() -> CallbackFuture<Bool>? {
        return nil
    }

    override func logout() -> CallbackFuture<Bool>? {
        return nil
    }

}
