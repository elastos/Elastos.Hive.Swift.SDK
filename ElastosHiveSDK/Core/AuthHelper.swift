import Foundation

@objc(AuthHelper)
class AuthHelper: NSObject {
    func login(authenticator: Authenticator) throws {
    }
    
    func checkExpired(_ hiveError: @escaping (_ error: HiveError?) -> Void) {
        
    }
    
    func getAuthInfo() -> AuthInfo? {
        return nil
    }
}
