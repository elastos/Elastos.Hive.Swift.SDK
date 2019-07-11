import Foundation


/// `Authenticator` is a protocol to use for grant authorization.
public protocol Authenticator {
    func requestAuthentication(_ requestURL: String) -> Bool
}
