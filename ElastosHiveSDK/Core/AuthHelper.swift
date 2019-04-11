import Foundation

@objc(AuthHelper)
class AuthHelper: NSObject {
    private var appId: String
    private var scopes: String
    private var redirectUrl: String

    override init() {
        self.appId = ""
        self.scopes = ""
        self.redirectUrl = ""
    }

    init(_ appId: String, _ scopes: String, _ redirectUrl: String) {
        self.appId = appId
        self.scopes = scopes
        self.redirectUrl = redirectUrl
    }

    func login(authenticator: Authenticator) {
    }
    
    func checkExpired() throws {
    }
}
