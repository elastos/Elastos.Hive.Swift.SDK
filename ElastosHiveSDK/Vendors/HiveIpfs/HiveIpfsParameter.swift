import Foundation

@objc(HiveIpfsParameter)
public class HiveIpfsParameter: DriveParameter {
    internal typealias authEntryType = NullEntry
    let uid: String
    let path: String

    public override func driveType() -> DriveType {
        return .hiveIpfs
    }

    public func getAuthEntry() -> NullEntry {
        return NullEntry()
    }

    public init(_ uid: String, _ path: String) {
        self.uid = uid
        self.path = path
        super.init()
        saveOnedriveAcount()
    }

    private func saveOnedriveAcount() {
        let ipfsdriveAccountJson = [KEYCHAIN_IPFS_UID: uid]
        HelperMethods.saveKeychain(.IPFSACCOUNT, ipfsdriveAccountJson)
    }


}
