import Foundation

@objc(IPFSParameter)
public class IPFSParameter: DriveParameter {
    internal typealias authEntryType = NullEntry
    let uid: String
    let path: String

    public override func driveType() -> DriveType {
        return .hiveIPFS
    }

    public func getAuthEntry() -> NullEntry {
        return NullEntry()
    }

    public init(_ uid: String, _ path: String) {
        self.uid = uid
        self.path = path
        super.init()
        KeyChainStore.writebackForIpfs(.hiveIPFS, uid)
    }
}
