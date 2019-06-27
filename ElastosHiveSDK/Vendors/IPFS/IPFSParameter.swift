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
        saveIpfsAcount()
    }

    private func saveIpfsAcount() {
        let statJson = KeyChainHelper.getKeychainForAll(.IPFSACCOUNT)
        let lastUid = statJson["last_uid"].stringValue
        guard lastUid != uid else {
            return
        }
        var uidArry = statJson["uids"].arrayValue
        let u = uidArry.filter { (item) -> Bool in
            let u = item["uid"].stringValue
            if u == uid{
                return true
            }
            else {
                return false
            }
            }.first
        if u != nil {
            uidArry.append(u!)
        }
        let ipfsAccountJson = ["last_uid": uid, "uids": uidArry] as [String : Any]
        KeyChainHelper.saveKeychain(.IPFSACCOUNT, ipfsAccountJson)
    }
}
