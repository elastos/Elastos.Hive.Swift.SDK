import Foundation

@objc(IPFSClinetOptions)
public class IPFSClientOptions: HiveClientOptions {
    private var _rpcNodes: Array<IPFSRpcNode>

    override init() {
        self._rpcNodes = Array<IPFSRpcNode>()
    }

    func addRpcNode(_ rpcNode: IPFSRpcNode) {
        self._rpcNodes.append(rpcNode)
    }

    public var rpcNodes: Array<IPFSRpcNode> {
        get {
            return _rpcNodes
        }
    }

    override func buildClient() -> HiveClientHandle {
        return IPFSClientHandle(self)
    }
}
