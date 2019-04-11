import Foundation

@objc(AuthResult)
public class AuthResult: NSObject {
    
    @objc public var authorCode: String?
    
    @objc(init:)
    public init(authorCode: String){
        super.init()
        self.authorCode = authorCode
    }
}
