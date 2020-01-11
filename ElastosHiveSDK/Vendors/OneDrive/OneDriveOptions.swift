import Foundation

public class OneDriveClientOptions: HiveClientOptions {
    private var _clientId: String?
    private var _redirectURL: String?
    private let _scope: String = ""

    override init() {
    }

    public var clientId: String? {
        get {
            return _clientId
        }
    }

    func setClientId(_ clientId: String) {
        self._clientId = clientId
    }

    public var redirectURL: String? {
        get {
            return _redirectURL
        }
    }

    func setRedirectURL(_ redirectURL: String) {
        self._redirectURL = redirectURL
    }

    public var scope: String {
        get {
            return _scope
        }
    }

    override func buildClient(_ options: HiveClientOptions) throws -> HiveClientHandle {
        return OneDriveClientHandle(options)
    }
}
