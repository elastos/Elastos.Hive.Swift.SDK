

import UIKit

public class HiveDirectoryHandle: NSObject {
    public var drive: HiveDriveHandle?
    public var pathName: String?
    public var parentPath: String?
    public var createDateTime: String?
    public var lastModifiedDateTime: String?
    public var parentReference: Dictionary<AnyHashable, Any>?


    public func parentHandle() -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        // TODO
        return nil
    }

    public func createDirectory(atName: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    public func getDirectory(atName: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    public func createFile(atName: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        return nil
    }

    public func fileHandle(atName: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        return nil
    }

    public func moveTo(atPath: String) -> CallbackFuture<Bool>? {
        return nil
    }

    public func copyTo(atPath: String) -> CallbackFuture<Bool>? {
        return nil
    }

    public func deleteItem() -> CallbackFuture<Bool>? {
        return nil
    }
}
