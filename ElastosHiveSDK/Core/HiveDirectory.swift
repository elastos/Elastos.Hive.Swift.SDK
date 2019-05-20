import Foundation
import PromiseKit

@objc(HiveDirectory)
public class HiveDirectoryHandle: NSObject {

    public var drive: HiveDriveHandle?
    private var _pathName: String?
    //public var parentPathName: String?
    public var parentPath: String?
    public var createDateTime: String?
    public var lastModifiedDateTime: String?
    public var parentReference: Dictionary<AnyHashable, Any>?


    // Get children.
}

extension HiveDirectoryHandle: HiveResourceItem {
    internal typealias resourceType = HiveDirectoryInfo

    @objc
    var lastInfo: resourceType  {
        get {
            return self.lastInfo
        }
        set (newInfo) {
            self.lastInfo = newInfo
        }
    }

    @objc
    var uniqueId: String {
        get {
            return self.uniqueId;
        }
    }

    func lastUpdatedInfo() -> Promise<resourceType>? {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryHandle.resourceType>())
    }

    func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> Promise<resourceType>? {
        // TODO
        return nil
    }
}

extension HiveDirectoryHandle: HiveFileItem {
    @objc
    public var pathName: String {
        get {
            return self.pathName
        }
    }

    @objc
    public var parentPathName: String {
        get {
            // TODO
            return self.pathName
        }
    }

    public func moveTo(newPath: String) -> Promise<HiveStatus>? {
        return moveTo(newPath: newPath, handleBy: HiveCallback<HiveStatus>())
    }

    public func moveTo(newPath: String, handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>? {
        // TODO;
        return nil;
    }

    public func copyTo(newPath: String) -> Promise<HiveStatus>? {
        return copyTo(newPath: newPath, handleBy: HiveCallback<HiveStatus>())
    }

    public func copyTo(newPath: String, handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>? {
        // TODO;
        return nil;
    }

    public func deleteItem() -> Promise<HiveStatus>? {
        return deleteItem(handleBy: HiveCallback<HiveStatus>())
    }

    public func deleteItem(handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>? {
        // TODO;
        return nil;
    }

    public func close() {
        // TODO
    }
}

extension  HiveDirectoryHandle: HiveDirectoryItem {
    public func createDirectory(withName: String) -> Promise<HiveDirectoryHandle>? {
        return createDirectory(withName: withName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    public func createDirectory(withName: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> Promise<HiveDirectoryHandle>? {
        // TODO
        return nil
    }

    public func directoryHandle(atName: String) -> Promise<HiveDirectoryHandle>? {
        return directoryHandle(atName: atName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    public func directoryHandle(atName: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> Promise<HiveDirectoryHandle>? {
        // TODO
        return nil
    }

    public func createFile(withName: String) -> Promise<HiveFileHandle>? {
        return createFile(withName: withName, handleBy: HiveCallback<HiveFileHandle>())
    }

    public func createFile(withName: String, handleBy: HiveCallback<HiveFileHandle>)
        -> Promise<HiveFileHandle>? {
        // TODO
        return nil
    }

    public func fileHandle(atName: String) -> Promise<HiveFileHandle>? {
        return fileHandle(atName: atName, handleBy: HiveCallback<HiveFileHandle>())
    }

    public func fileHandle(atName: String, handleBy: HiveCallback<HiveFileHandle>)
        -> Promise<HiveFileHandle>? {
        // TODO
        return nil
    }

    // Get children.
}
