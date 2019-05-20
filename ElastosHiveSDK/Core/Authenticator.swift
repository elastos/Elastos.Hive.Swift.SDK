import Foundation

public protocol Authenticator {
    func requestAuthentication(_ requestURL: String) -> Bool
}
