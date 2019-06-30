
import Foundation

class AuthToken: NSObject {
    var expiredIn: Int64 = 0
    var accessToken: String = ""
    var refreshToken: String = ""
    var expiredTime: String = ""

    func isExpired() -> Bool {
        return Timestamp.isAfter(expiredTime)
    }
}
