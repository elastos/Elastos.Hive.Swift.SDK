import Foundation

@objc(OwnCloudParameter)
public class OwnCloudParameter: DriveParameter {
    internal typealias authEntryType = NullEntry

    public var driveType: DriveType {
        get {
            return .ownCloud
        }
    }

    public func getAuthEntry() -> NullEntry {
        return NullEntry()
    }
}
