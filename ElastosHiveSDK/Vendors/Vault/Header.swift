
import Foundation

class Header {
    private var auther: ConnectHelper

    init(_ auther: ConnectHelper) {
        self.auther = auther
    }

    func headers() -> HTTPHeaders {
        let accesstoken: String = (self.auther as! VaultAuthHelper).token?.accessToken ?? ""
        return ["Content-Type": "application/json", "Authorization": "token \(accesstoken)"]
    }
}
