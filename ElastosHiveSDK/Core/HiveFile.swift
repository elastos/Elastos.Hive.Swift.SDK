import Foundation
import PromiseKit

@objc(HiveFile)
public class HiveFileHandle: NSObject, HiveResourceItem, HiveFileItem {
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

    private var _pathName: String
    private let fileId: String
    private let authHelper: AuthHelper?
    private var _lastInfo: HiveFileInfo?

    init(_ info: HiveFileInfo, _ authHelper: AuthHelper) {
        self._lastInfo = info
        self.authHelper = authHelper
        self.fileId = "TODO"
        self._pathName = "TODO"
    }

    @objc
    public var handleId: String? {
        get {
            return self.fileId;
        }
    }

    public typealias resourceType = HiveFileInfo
    @objc
    public var lastInfo: resourceType?  {
        get {
            return self._lastInfo
        }
        set (newInfo) {
            self._lastInfo = newInfo
        }
    }

    public func lastUpdatedInfo() -> Promise<resourceType>? {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileHandle.resourceType>())
    }

    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> Promise<resourceType>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveFileInfo>(error: error)
    }

    @objc
    public var pathName: String {
        get {
            return self._pathName
        }
    }

    @objc
    public var parentPathName: String {
        get {
            // TODO
            return self._pathName
        }
    }

    public func moveTo(newPath: String) -> Promise<HiveStatus>? {
        return moveTo(newPath: newPath, handleBy: HiveCallback<HiveStatus>())
    }

    public func moveTo(newPath: String, handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveStatus>(error: error)
    }

    public func copyTo(newPath: String) -> Promise<HiveStatus>? {
        return copyTo(newPath: newPath, handleBy: HiveCallback<HiveStatus>())
    }

    public func copyTo(newPath: String, handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveStatus>(error: error)
    }

    public func deleteItem() -> Promise<HiveStatus>? {
        return deleteItem(handleBy: HiveCallback<HiveStatus>())
    }

    public func deleteItem(handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>? {
        let error = HiveError.failue(des: "Dummy")
        return Promise<HiveStatus>(error: error)
    }

    public func close() {
        // TODO
    }
}
