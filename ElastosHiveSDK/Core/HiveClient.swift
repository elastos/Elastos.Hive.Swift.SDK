import Foundation

/// An alias global type of `Promise`.
public typealias HivePromise = Promise

@objc(HiveClient)
public class HiveClientHandle: NSObject {
    override init() {
    }

    public func connect() throws {
    }

    public func disconnect() {
    }

    public func asFiles() -> FilesProtocol? {
        return nil
    }

    public func asIPFS() -> IPFSProtocol? {
        return nil
    }

    public func asKeyValues() -> KeyValuesProtocol? {
        return nil
    }

    public static func createInstance(_ options: HiveClientOptions) throws -> HiveClientHandle {
        // TODO;
    }
}
