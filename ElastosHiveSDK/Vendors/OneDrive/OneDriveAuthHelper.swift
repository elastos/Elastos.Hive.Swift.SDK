import UIKit

@objc(OneDriveAuthHelper)
public class OneDriveAuthHelper: AuthHelper {
    
    private var authInfo: AuthInfo?
    public override init(appId: String, scopes: String, redirectUrl: String) {
        super.init(appId: appId, scopes: scopes, redirectUrl: redirectUrl)
        self.appId = appId
        self.scopes = scopes
        self.redirectUrl = redirectUrl
    }
    
    public override func login(authenticator: Authenticator) -> Bool {
        if(!hasLogin()){
            let result: AuthResult = authenticator.requestAuthentication()
            if(result.authorCode == "")
            {
                return false
            }
            try? requestAccessToken(authorCode: result.authorCode!)
        }
        if(isExpired()){
            try? refreshAccessToken()
        }
        return hasLogin()
    }
    
    private func requestAccessToken(authorCode: String) throws {
        // todo
    }
    
    private func refreshAccessToken() throws {
        // todo
    }
    
    private func hasLogin() -> Bool {
        if(authInfo != nil){
            return true
        }
        return false
    }
    
    private func isExpired() -> Bool {
        return (authInfo?.isExpired())!
    }
    
    override public func checkExpired() throws {
        // todo
    }
    
    
    
}

