
import Foundation

class Header {
    private var auther: AuthHelper
    
    init(_ auther: AuthHelper) {
        self.auther = auther
    }
    
    func plain_headers() -> HTTPHeaders {
        let accesstoken: String = (self.auther as! OneDriveAuthHelper).token?.accessToken ?? ""
        return ["Content-Type": "text/plain", "Authorization": "bearer \(accesstoken)"]
    }
    
    func json_Headers() -> HTTPHeaders {
        let accesstoken: String = (self.auther as! OneDriveAuthHelper).token?.accessToken ?? ""
        return ["Content-Type": "application/json;charset=UTF-8", "Authorization": "bearer \(accesstoken)"]
    }

}
