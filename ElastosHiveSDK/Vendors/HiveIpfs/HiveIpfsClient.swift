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

    override func authHelper() -> AuthHelper {
        return AuthHelper()
    }

    override func driveType() -> DriveType {
        return .ownCloud
    }

    override func login(withResult: @escaping (HiveResultHandler)) {
        // TODO
    }

    override func logout(withResult: @escaping (HiveResultHandler)) {
        // TODO
    }
}
