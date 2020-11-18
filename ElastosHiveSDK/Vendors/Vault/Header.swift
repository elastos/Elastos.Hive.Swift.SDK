
import Foundation

class Header {
    private var auther: ConnectHelper

    init(_ auther: ConnectHelper) {
        self.auther = auther
    }

    func headers() -> HTTPHeaders {
        let accesstoken: String = (self.auther as! VaultAuthHelper).token?.accessToken ?? ""
        return [/*"Content-Type": "application/json;charset=UTF-8",*/ "Authorization": "token \(accesstoken)", "Transfer-Encoding": "chunked", "Connection": "Keep-Alive"]
    }
}
