
import Foundation

class Header {
    private var auther: ConnectHelper

    init(_ auther: ConnectHelper) {
        self.auther = auther
    }

    func headersStream() -> HTTPHeaders {
        let accesstoken: String = (self.auther as! VaultAuthHelper).token?.accessToken ?? ""
        return ["Content-Type": "application/octet-stream", "Authorization": "token \(accesstoken)", "Transfer-Encoding": "chunked", "Connection": "Keep-Alive"]
    }
    
    func headers() -> HTTPHeaders {
        let accesstoken: String = (self.auther as! VaultAuthHelper).token?.accessToken ?? ""
        return ["Content-Type": "application/json;charset=UTF-8", "Authorization": "token \(accesstoken)"]
    }
    
    func NormalHeaders() -> HTTPHeaders {
        return ["Content-Type": "application/json;charset=UTF-8"]
    }
}
