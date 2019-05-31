import Foundation
import PromiseKit

@objc(HiveFile)
public class HiveFileHandle: NSObject, HiveResourceItem, HiveFileItem {
    public typealias resourceType = HiveFileInfo
    public var drive: HiveDriveHandle?
    public var fileId: String
    public var pathName: String
    public var lastInfo: HiveFileInfo
    var authHelper: AuthHelper?

    init(_ info: HiveFileInfo, _ authHelper: AuthHelper) {
        self.lastInfo = info
        self.authHelper = authHelper
        self.fileId = lastInfo.fileId
        self.pathName = ""
    }
    
    public func parentPathName() -> String {
        return ""
    }

    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileHandle.resourceType>())
    }

    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileInfo>(error: error)
    }

    public func moveTo(newPath: String) -> HivePromise<Bool> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    public func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    public func copyTo(newPath: String) -> HivePromise<Bool> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    public func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    public func deleteItem() -> HivePromise<Bool> {
        return deleteItem(handleBy: HiveCallback<Bool>())
    }

    public func deleteItem(handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    public func readData() -> HivePromise<String> {
        return readData(handleBy: HiveCallback<String>())
    }

    public func readData(handleBy: HiveCallback<String>) -> HivePromise<String> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<String>(error: error)
    }

    public func writeData(withData: Data) -> HivePromise<Bool> {
        return writeData(withData: withData, handleBy: HiveCallback<Bool>())
    }

    public func writeData(withData: Data, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }
    public func close() {
        // TODO
    }
}
