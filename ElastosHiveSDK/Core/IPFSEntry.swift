

import UIKit

public class IPFSEntry {

    var uid: String
    let rpcAddrs: Array<String>
    public init(_ uid: String, _ rpcAddrs: Array<String>) {
        self.uid = uid
        self.rpcAddrs = rpcAddrs
    }
}
