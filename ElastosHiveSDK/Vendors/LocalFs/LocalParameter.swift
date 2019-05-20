import Foundation

@objc(LocalParameter)
public class LocalParameter: DriveParameter {
    internal typealias authEntryType = NullEntry

    public var driveType: DriveType {
        get {
            return DriveType.local
        }
    }

    public func getAuthEntry() -> NullEntry {
        return NullEntry()
    }
}
