
import Foundation

class AuthToken: NSObject {
    var expiredIn: Int64?
    var accessToken: String?
    var refreshToken: String?
    var scopes: String?
    var expiredTime: String?

    func isExpired() -> Bool {
        return ConvertHelper.checkIsExpired(self.expiredTime!)
    }
}
