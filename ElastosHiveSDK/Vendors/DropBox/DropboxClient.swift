import Foundation

@objc(DropboxClient)
internal class DropboxClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private var authHelperHandle: AuthHelper?

    private init(_ param: DriveParameters) {
        // TODO;
        //super.init()
    }

    @objc(createInstance:)
    public static func createInstance(param: DriveParameters){
        if clientInstance == nil {
            let client: DropboxClient = DropboxClient(param)
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
