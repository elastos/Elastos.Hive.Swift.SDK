import Foundation
import PromiseKit

@objc(HiveFile)
public class HiveFileHandle: NSObject {
    public var drive: HiveDriveHandle?
    public var createdDateTime: String?
    public var lastModifiedDateTime: String?
    public var isFile: Bool?
    public var isDirectory: Bool?
    public var id: String?
    //public var pathName: String?
    public var name: String?
    public var rootPath: String?
    public var parentId: String?
    public var parentPath: String?
    public var driveId: String?
    public var fileSystemInfo: Dictionary<AnyHashable, Any>?
    public var parentReference: Dictionary<AnyHashable, Any>?
    public var createDateTime: String?
}

extension HiveFileHandle: HiveResourceItem {
    internal typealias resourceType = HiveFileInfo

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
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileHandle.resourceType>())
    }

    func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> Promise<resourceType>? {
        // TODO
        return nil
    }
}

extension HiveFileHandle: HiveFileItem {
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
