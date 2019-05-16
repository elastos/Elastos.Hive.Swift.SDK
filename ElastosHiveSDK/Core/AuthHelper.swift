import Foundation

@objc(AuthHelper)
internal class AuthHelper: NSObject {
    
    func checkExpired() -> CallbackFuture<Bool>?{
        return nil
    }
    
    func getAuthInfo() -> AuthInfo? {
        return nil
    }
}
