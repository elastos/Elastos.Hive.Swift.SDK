import Foundation

@objc(AuthInfo)
class AuthInfo: NSObject {
    var expiredIn: Int64!
    var accessToken: String!
    var refreshToken: String!
    var scopes: String!
    
    @objc(init:accessToken:refreshToken:expiredIn:)
    init(_ scopes: String, _ accessToken: String, _ refreshToken: String, _ expiredIn: Int64) {
        super.init()
        self.expiredIn = expiredIn
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.scopes = scopes
    }

    @objc(resetAccessToken:)
    func resetAccessToken(accessToken: String) {
        self.accessToken = accessToken
    }

    @objc(isExpired)
    func isExpired() -> Bool{
        // todo
        return false
    }
}
