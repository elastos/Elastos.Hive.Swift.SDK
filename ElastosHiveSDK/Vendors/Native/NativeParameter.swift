import Foundation

@objc(NativeParameter)
public class NativeParameter: DriveParameter {
    internal typealias authEntryType = NullEntry

    public var driveType: DriveType {
        get {
            return .nativeStorage
        }
    }

    public func getAuthEntry() -> NullEntry {
        return NullEntry()
    }
}
