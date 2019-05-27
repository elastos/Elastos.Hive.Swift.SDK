import Foundation
import PromiseKit

@objc(HiveFile)
public class HiveFileHandle: NSObject, HiveResourceItem, HiveFileItem {
    public var drive: HiveDriveHandle?
    public var fileId: String?
    public var pathName: String?
    public var name: String?
    public var createdDateTime: String?
    public var lastModifiedDateTime: String?
    public var parentPathName: String?
    public var fileSystemInfo: Dictionary<String, Any>?
    public var parentReference: Dictionary<String, Any>?

    let authHelper: AuthHelper?
    private var _lastInfo: HiveFileInfo?

    init(_ info: HiveFileInfo, _ authHelper: AuthHelper) {
        self._lastInfo = info
        self.authHelper = authHelper
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

    public func lastUpdatedInfo() -> HivePromise<resourceType>? {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileHandle.resourceType>())
    }

    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType>? {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileInfo>(error: error)
    }

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

   public func readData() -> HivePromise<String>? {
        return readData(handleBy: HiveCallback<String>())
    }

    public func readData(handleBy: HiveCallback<String>) -> HivePromise<String>? {
        return nil
    }

   public func writeData(withData: Data) -> HivePromise<Bool>? {
        return writeData(withData: withData, handleBy: HiveCallback<Bool>())
    }

   public func writeData(withData: Data, handleBy: HiveCallback<Bool>) -> HivePromise<Bool>? {
        return nil
    }
    public func close() {
        // TODO
    }
}
