import Foundation

@objc(IPFSRpcNode)
public class IPFSRpcNode: NSObject {
    private let _ipv4: String
    private let _ipv6: String?
    private let _port: UInt16

    public init(_ ipv4: String, _ port: UInt16) {
        self._ipv4 = ipv4
        self._port = port
        self._ipv6 = nil
    }

    public convenience init(_ ipv4: String, _ ipv6: String, _ port: UInt16) {
        self.init(ipv4, port)
    }

    public var ipv4: String {
        get {
            return _ipv4
        }
    }

    public var ipv6: String? {
        get {
            return _ipv6
        }
    }

    public var port: UInt16 {
        get {
            return _port;
        }
    }
}
