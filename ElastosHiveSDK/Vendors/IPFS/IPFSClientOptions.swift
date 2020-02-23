import Foundation

@objc(IPFSClientOptions)
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

    override func checkValid(_ all: Bool) -> Bool {
        return _rpcNodes.count > 0 && super.checkValid(all)
    }

    func checkValid() -> Bool {
        return checkValid(false)
    }

    override func buildClient() -> HiveClientHandle? {
        return IPFSClientHandle(self)
    }
}
