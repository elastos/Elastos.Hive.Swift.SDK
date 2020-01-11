import Foundation

@objc(HiveClientOptions)
public class HiveClientOptions: NSObject {
    private var _storePath: String?
    private var _authenticator: Authenticator?

    override init() {
        super.init()
    }

    public var storePath: String? {
        get {
            return _storePath
        }
    }

    func setStorePath(_ storePath: String) {
        self._storePath = storePath
    }

    public var authenicator: Authenticator? {
        get {
            return _authenticator
        }
    }

    func setAuthenticator(_ authenticator: Authenticator) {
        self._authenticator = authenticator
    }

    func buildClient() -> HiveClientHandle {
        return IPFSClientHandle(self)
    }
}
