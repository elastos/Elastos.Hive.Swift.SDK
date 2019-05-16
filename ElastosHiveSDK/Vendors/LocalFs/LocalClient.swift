import Foundation

@objc(LocalClient)
internal class LocalClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private var authHelperHandle: AuthHelper?

    private init(_ param: LocalParameters) {
    }

    @objc(createInstance:)
    private static func createInstance(param: LocalParameters) {
        if clientInstance == nil {
            let client: LocalClient = LocalClient(param)
            clientInstance = client as HiveClientHandle
        }
    }

    static func sharedInstance() -> HiveClientHandle? {
        return clientInstance
    }

    override func driveType() -> DriveType {
        return .local
    }

    override func login() -> CallbackFuture<Bool>? {
        return nil
    }
    override func logout() -> CallbackFuture<Bool>? {
        //TODO
        return nil
    }

}
