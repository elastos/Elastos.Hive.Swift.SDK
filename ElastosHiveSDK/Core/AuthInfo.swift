import Foundation

@objc(AuthInfo)
class AuthInfo: NSObject {
    var expiredIn: Int64!
    var accessToken: String!
    var refreshToken: String!
    var scopes: String!

    public func isExpired() -> Bool {
        // TODO
        return false
    }
}
