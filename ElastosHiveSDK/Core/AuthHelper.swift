import Foundation

@objc(AuthHelper)
class AuthHelper: NSObject {
    func login(authenticator: Authenticator) throws {
    }
    
    func checkExpired() throws {
    }
    
    func getAuthInfo() -> AuthInfo? {
        return nil
    }
}
