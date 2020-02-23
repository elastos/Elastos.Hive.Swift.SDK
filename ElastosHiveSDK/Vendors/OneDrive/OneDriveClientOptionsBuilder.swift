import Foundation

@objc(OneDriveClientOptionsBuilder)
public class OneDriveClientOptionsBuilder: NSObject {
    private var options: OneDriveClientOptions?

    public override init() {
        options = OneDriveClientOptions()
        super.init()
    }

    public func withClientId(_ clientId: String) -> OneDriveClientOptionsBuilder {
        options?.setClientId(clientId)
        return self
    }

    public func withRedirectUrl(_ redirectUrl: String) -> OneDriveClientOptionsBuilder {
        options?.setRedirectUrl(redirectUrl)
        return self
    }

    public func withAuthenticator(_ authenticator: Authenticator) -> OneDriveClientOptionsBuilder {
        options?.setAuthenticator(authenticator)
        return self
    }

    public func withStorePath(using path: String) -> OneDriveClientOptionsBuilder {
        options?.setStorePath(path)
        return self
    }

    public func build() throws -> OneDriveClientOptions {
        guard let _ = options else {
            throw HiveError.invalidatedBuilder(des: "Invalidated builder")
        }

        guard !options!.checkValid() else {
            throw HiveError.insufficientParameters(des: "Imcomplete options fields")
        }

        let _options = self.options!
        self.options = nil
        return _options
    }
}
