import Foundation

@objc(AuthInfo)
internal class AuthInfo: NSObject {
    var expiredIn: Int64?
    var accessToken: String?
    var refreshToken: String?
    var scopes: String?
    var expiredTime: String?

    func isExpired() -> Bool {
        return HelperMethods.checkIsExpired(self.expiredTime!)
    }
}
