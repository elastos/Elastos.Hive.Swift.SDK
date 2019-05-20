import Foundation

class AuthToken: NSObject {
    let scope: String
    let refreshToken: String
    let accessToken: String
    let expiresIn: String

    init(_ scope: String, _ refreshToken: String, _ accessToken: String, _ expiresIn: String) {
        self.scope = scope
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        self.expiresIn = expiresIn
    }

    func isExpired() -> Bool {
        // TODO
        return false
    }
}
