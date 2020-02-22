import Foundation

@objc(OneDriveClientOptions)
public class OneDriveClientOptions: HiveClientOptions {
    private static let APP_FOLDER_SCOPE = "Files.ReadWrite.AppFolder offline_access"

    private let _scope = OneDriveClientOptions.APP_FOLDER_SCOPE
    private var _clientId: String?
    private var _redirectUrl: String?

    override init() {}

    public var clientId: String {
        get {
            return _clientId!
        }
    }

    func setClientId(_ clientId: String) {
        self._clientId = clientId
    }

    public var redirectUrl: String {
        get {
            return _redirectUrl!
        }
    }

    func setRedirectUrl(_ redirectUrl: String) {
        self._redirectUrl = redirectUrl
    }

    public var scope: String {
        get {
            return _scope
        }
    }

    override func checkValid(_ all: Bool) -> Bool {
        return _clientId != nil && _redirectUrl != nil && super.checkValid(all)
    }

    func checkValid() -> Bool {
        return checkValid(true)
    }

    override func buildClient() -> HiveClientHandle? {
        return OneDriveClientHandle(self)
    }
}
