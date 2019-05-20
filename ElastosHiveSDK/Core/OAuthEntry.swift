import Foundation

public class OAuthEntry {
    let clientId: String
    let scope   : String
    let redirectURL: String

    public init(_ clientId: String,  _ scope: String, _ redirectURL: String) {
        self.clientId = clientId
        self.scope = scope
        self.redirectURL = redirectURL
    }
}
