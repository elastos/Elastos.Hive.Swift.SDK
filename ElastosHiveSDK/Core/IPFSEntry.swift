

import Foundation

/// Configuration for the ipfs params
public class IPFSEntry {

    /// A unique UID. The UID can be used to identify endpoints in communication.
    var uid: String

    /// Ipfs address
    let rpcAddrs: Array<String>
    public init(_ uid: String, _ rpcAddrs: Array<String>) {
        self.uid = uid
        self.rpcAddrs = rpcAddrs
    }
}
