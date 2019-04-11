import Foundation

@objc(AuthInfo)
public class AuthInfo: NSObject {
    
    public var expiredIn: Int64!
    @objc public var accessToken: String!
    @objc public var refreshToken: String!
    @objc public var scopes: String!
    
    @objc(init:accessToken:refreshToken:expiredIn:)
    public init(scopes: String, accessToken: String, refreshToken: String, expiredIn: Int64) {
        super.init()
        self.expiredIn = expiredIn
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.scopes = scopes
    }
    
    @objc(resetAccessToken:)
    public func resetAccessToken(accessToken: String) {
        self.accessToken = accessToken
    }
    
    @objc(isExpired)
    public func isExpired() -> Bool{
        // todo
        return false
    }
    
    
}
