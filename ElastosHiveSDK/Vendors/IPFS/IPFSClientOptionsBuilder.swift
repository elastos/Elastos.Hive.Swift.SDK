import Foundation

public class IPFSClientOptionsBuilder {
    private var options: IPFSClientOptions?

    public init() {
        options = IPFSClientOptions()
    }

    public func appendRpcNode(_ aNode: IPFSRpcNode) -> IPFSClientOptionsBuilder {
        options?.addRpcNode(aNode)
        return self
    }

    public func withStorePath(using path: String) -> IPFSClientOptionsBuilder {
        options?.setStorePath(path)
        return self
    }

    public func build() throws -> IPFSClientOptions {
        guard options?.rpcNodes.count ?? 0 > 0 else {
            // TODO;
        }

        guard options?.storePath != nil else {
            // TODO
        }

        let _options: IPFSClientOptions = self.options!
        self.options = nil
        return _options
    }
}
