
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
    
    func upload_Headers(_ length: Int64) -> HTTPHeaders {
        var end: Int64 = length - 1
        if length == 0 {
            end = length
        }
        let accesstoken: String = (self.auther as! OneDriveAuthHelper).token?.accessToken ?? ""
        return ["Content-Type": "application/json;charset=UTF-8", "Authorization": "bearer \(accesstoken)", "Content-Length": "\(length)", "Content-Range": "bytes 0-\(end)/\(length)"]
    }
}
