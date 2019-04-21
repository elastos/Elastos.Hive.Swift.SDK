import Foundation

@objc(AuthHelper)
internal class AuthHelper: NSObject {
    func login(_ authenticator: Authenticator) throws {
    }

    func checkExpired(_ errorHandler: @escaping (_ error: HiveError?) -> Void) {
        
    }
    
    func getAuthInfo() -> AuthInfo? {
        return nil
    }
}
