import Foundation
import PromiseKit

@objc(HiveDirectory)
public class HiveDirectoryHandle: NSObject, HiveResourceItem, HiveFileItem, HiveDirectoryItem {

    public var drive: HiveDriveHandle?
    public var directoryId: String?
    public var pathName: String?
    public var name: String?
    public var parentReference: Dictionary<String, Any>?
    public var createdDateTime: String?
    public var lastModifiedDateTime: String?
    public var parentPathName: String?

    private var _lastInfo: HiveDirectoryInfo?
    internal let authHelper: AuthHelper

    init(_ info: HiveDirectoryInfo, _ authHelper: AuthHelper) {
        self._lastInfo = info
        self.authHelper = authHelper
        self.directoryId = "TODO"
    }

    public typealias resourceType = HiveDirectoryInfo
    @objc
    public var lastInfo: resourceType? {
        get {
            return self._lastInfo
        }
        set (newInfo) {
            self._lastInfo = newInfo
        }
    }

    public func lastUpdatedInfo() -> HivePromise<resourceType>? {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryHandle.resourceType>())
    }

    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType>? {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryInfo>(error: error)
    }

    public func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle>? {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    public func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle>? {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    public func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle>? {
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    public func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle>? {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    public func createFile(withPath: String) -> HivePromise<HiveFileHandle>? {
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    public func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle>? {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }

    public func fileHandle(atPath: String) -> HivePromise<HiveFileHandle>? {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    public func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle>? {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }
    // Get children.

    public func moveTo(newPath: String) -> HivePromise<Bool>? {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    public func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool>? {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    public func copyTo(newPath: String) -> HivePromise<Bool>? {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    public func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool>? {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    public func deleteItem() -> HivePromise<Bool>? {
        return deleteItem(handleBy: HiveCallback<Bool>())
    }

    public func deleteItem(handleBy: HiveCallback<Bool>) -> HivePromise<Bool>? {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    public func close() {
        // TODO
    }
}
