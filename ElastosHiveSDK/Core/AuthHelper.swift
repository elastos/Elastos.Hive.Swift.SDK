import Foundation

@objc(AuthHelper)
internal class AuthHelper: NSObject {
    
    func checkExpired() -> CallbackFuture<Bool>?{
        return nil
    }
    
    func getAuthInfo() -> AuthInfo? {
        return nil
    }
    
    func headers() -> [String: Any] {
        let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
        return ["Content-Type": "application/json;charset=UTF-8", HTTP_HEADER_AUTHORIZATION: "bearer \(accesstoken)"]
    }
}
