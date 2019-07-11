
import Foundation


///  The `AuthToken` object is a property bag for storing information needed to make authentication requests.
///  @see https://dev.onedrive.com/auth/readme.htm.
class AuthToken: NSObject {

    ///  The length of the access token expires
    var expiredIn: Int64 = 0

    ///  The access token for the user.
    var accessToken: String = ""

    /// The refresh token to when refreshing the access token.
    var refreshToken: String = ""

    ///  The time stamp indicating when the access token expires
    var expiredTime: String = ""

    /// Check access token isExpired
    /// - Returns:  Returns `true` if expired, `false` otherwise.
    func isExpired() -> Bool {
        return Timestamp.isAfter(expiredTime)
    }
}
