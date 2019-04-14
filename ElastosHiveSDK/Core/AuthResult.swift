import Foundation


public class AuthResult: NSObject {
    
    private var authorCode: String?
    private var errorCode: String?
    
    public init(authorCode: String?, errorCode: String?){
        super.init()
        self.authorCode = authorCode
        self.errorCode = errorCode
    }
    
    public func isAuthorized() -> Bool? {
        return authorCode!.count > 0
    }
    
}
