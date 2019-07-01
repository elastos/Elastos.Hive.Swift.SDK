import Foundation

@objc(IPFSParameter)
public class IPFSParameter: DriveParameter {
    internal typealias authEntryType = NullEntry
    var uid: String

    public override func driveType() -> DriveType {
        return .hiveIPFS
    }

    public func getAuthEntry() -> NullEntry {
        return NullEntry()
    }

    public init(_ uid: String) {
        self.uid = uid
        super.init()
        KeyChainStore.writebackForIpfs(.hiveIPFS, uid)
    }
}
