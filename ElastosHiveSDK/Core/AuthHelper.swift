import UIKit

@objc(AuthHelper)
public class AuthHelper: NSObject {

    var appId: String = ""
    var scopes: String = ""
    var redirectUrl: String = ""
    
    public func login(authenticator: Authenticator) -> Bool{
        return false
    }
    
    public init(appId: String, scopes: String, redirectUrl: String) {

        self.appId = appId
        self.scopes = scopes
        self.redirectUrl = redirectUrl
    }
    
    public func checkExpired() throws{}
    
}
