import Foundation

@objc(DropBoxParameter)
public class DropBoxParameter: DriveParameter {
    internal typealias authEntryType = OAuthEntry
    private let authEntry: OAuthEntry

    public init(_ clientId: String, _ scope: String, _ redirectURL: String)  {
        authEntry = OAuthEntry(clientId, scope, redirectURL)
    }

    public var driveType: DriveType {
        get {
            return DriveType.dropBox
        }
    }

    public func getAuthEntry() -> OAuthEntry {
        return self.authEntry
    }
}
