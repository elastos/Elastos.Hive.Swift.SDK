import Foundation


class AuthCode: Result {

    public final var authCode: String
    init(_ authCode: String) {
        self.authCode = authCode
    }
}
