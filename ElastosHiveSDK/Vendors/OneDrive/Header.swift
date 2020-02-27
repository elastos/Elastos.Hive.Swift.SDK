
import Foundation

class Header {
    private var auther: ConnectHelper
    
    init(_ auther: ConnectHelper) {
        self.auther = auther
    }
    
    func plain_headers() -> HTTPHeaders {
        let accesstoken: String = (self.auther as! OneDriveAuthHelper).token?.accessToken ?? ""
        return ["Content-Type": "application/octet-stream", "Authorization": "bearer \(accesstoken)"]
    }
    
    func json_Headers() -> HTTPHeaders {
        let accesstoken: String = (self.auther as! OneDriveAuthHelper).token?.accessToken ?? ""
        return ["Content-Type": "application/json;charset=UTF-8", "Authorization": "bearer \(accesstoken)"]
    }

}
