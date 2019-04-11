import Foundation

@objc(Authenticator)
public class Authenticator: NSObject {
    
    @objc(requestAuthentication)
    public func requestAuthentication() -> AuthResult{

        return AuthResult(authorCode: "")
    }
    
}
