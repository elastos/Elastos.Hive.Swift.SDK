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

        guard options?.clientId != nil else {
            throw HiveError.insufficientParameters(des: "Missing clientId")
        }

        guard options?.redirectUrl != nil else {
            throw HiveError.insufficientParameters(des: "Missing redirectUrl")
        }

        guard options?.storePath != nil else {
            throw HiveError.insufficientParameters(des: "Missing storePath")
        }

        guard options?.authenicator != nil else {
            throw HiveError.insufficientParameters(des: "Missing authenticator delegate")
        }

        let _options: OneDriveClientOptions = self.options!
        self.options = nil
        return _options
    }
}
