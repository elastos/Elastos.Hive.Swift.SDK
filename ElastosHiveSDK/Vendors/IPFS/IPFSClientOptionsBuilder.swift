import Foundation

@objc(IPFSClientOptionsBuilder)
public class IPFSClientOptionsBuilder: NSObject {
    private var options: IPFSClientOptions?

    public override init() {
        options = IPFSClientOptions()
        super.init()
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
        guard let _ = options else {
            throw HiveError.invalidatedBuilder(des: "Invalidated builder")
        }

        guard options!.checkValid() else {
            throw HiveError.insufficientParameters(des: "Incomplete IPFSClient Options")
        }

        let _options: IPFSClientOptions = self.options!
        self.options = nil
        return _options
    }
}
