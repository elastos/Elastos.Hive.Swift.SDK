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
