import Foundation

public class OneDriveClientOptionsBuilder {
    private var options: OneDriveClientOptions?

    public init() {
        options = OneDriveClientOptions()
    }

    public func withClientId(_ clientId: String) -> OneDriveClientOptionsBuilder {
        options?.setClientId(clientId)
        return self
    }

    public func withRedirectUrl(_ redirectUrl: String) -> OneDriveClientOptionsBuilder {
        options?.setRedirectURL(redirectUrl)
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
        guard options?.clientId != nil else {
            // TODO;
        }

        guard options?.redirectURL != nil else {
            // TODO
        }

        guard options?.storePath != nil else {
            // TODO
        }

        guard options?.authenicator != nil else {
            // TODO
        }

        let _options: OneDriveClientOptions = self.options!
        self.options = nil
        return _options
    }
}
