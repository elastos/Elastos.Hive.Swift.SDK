import Foundation

@objc(OneDriveParameter)
public class OneDriveParameter: DriveParameter {
    internal typealias authEntryType = OAuthEntry
    private let authEntry: OAuthEntry

    public init(_ clientId: String, _ scope: String, _ redirectURL: String) {
        self.authEntry = OAuthEntry(clientId, scope, redirectURL)
    }

    public var driveType: DriveType {
        get {
            return DriveType.oneDrive
        }
    }

    public func getAuthEntry() -> OAuthEntry {
        return self.authEntry
    }
}
