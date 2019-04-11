import Foundation

@objc(OneDriveAuthHelper)
class OneDriveAuthHelper: AuthHelper {
    private var authInfo: AuthInfo?
    public override init(_ appId: String, _ scopes: String, _ redirectUrl: String) {
        super.init(appId, scopes, redirectUrl)
    }
    
    override func login(authenticator: Authenticator) {
        if(!hasLogin()){
            let result: AuthResult = authenticator.requestAuthentication()
            if(result.authorCode == "") {
                return
            }
            try? requestAccessToken(authorCode: result.authorCode!)
        }

        if(isExpired()){
            try? refreshAccessToken()
        }
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
