import Foundation

public typealias HivePromise = Promise

@objc(HiveClient)
public class HiveClientHandle: NSObject {
    override init() {}

    public func connect() throws {}
    public func connectAsync() -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
    }

    public func disconnect() {}
    public func isConnected() -> Bool {
        return false
    }

    public func asFiles() -> FilesProtocol? {
        return nil
    }

    public func asDatabase() -> DatabaseProtocol? {
        return nil
    }

    public func asKeyValues() -> KeyValuesProtocol? {
        return nil
    }

    public func asScripting() -> ScriptingProtocol? {
        return nil
    }

    public static func createInstance(withOptions: HiveClientOptions) throws -> HiveClientHandle {
        let client = withOptions.buildClient()
        guard client != nil else {
            throw HiveError.failue(des: "Not implemented")
        }

        return client!
    }
}
