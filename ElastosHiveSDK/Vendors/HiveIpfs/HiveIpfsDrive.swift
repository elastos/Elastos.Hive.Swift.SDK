import Foundation
import PromiseKit

@objc(HiveIpfsDrive)
internal class HiveIpfsDrive: HiveDriveHandle {
    init(_ info: HiveDriveInfo) {
        super.init(DriveType.hiveIpfs, info)
    }

    override func lastUpdatedInfo() -> Promise<HiveDriveInfo>? {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>) -> Promise<HiveDriveInfo>? {
        let error = HiveError.failue(des: "TODO")
        return Promise<HiveDriveInfo>(error: error)
    }

    override func rootDirectoryHandle() -> Promise<HiveDirectoryHandle>? {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>) ->
        Promise<HiveDirectoryHandle>? {
        let error = HiveError.failue(des: "TODO")
        return Promise<HiveDirectoryHandle>(error: error)
    }

    override func createDirectory(withPath: String) -> Promise<HiveDirectoryHandle>? {
        return createDirectory(withPath: withPath,
                               handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        Promise<HiveDirectoryHandle>? {
        let error = HiveError.failue(des: "TODO")
        return Promise<HiveDirectoryHandle>(error: error)
    }

    override func directoryHandle(atPath: String) -> Promise<HiveDirectoryHandle>? {
        return directoryHandle(atPath: atPath,
                             handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        Promise<HiveDirectoryHandle>? {
        let error = HiveError.failue(des: "TODO")
        return Promise<HiveDirectoryHandle>(error: error)
    }

    override func createFile(withPath: String) -> Promise<HiveFileHandle>? {
        return createFile(withPath: withPath,
                          handleBy: HiveCallback<HiveFileHandle>())
    }

    override func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        Promise<HiveFileHandle>? {
        let error = HiveError.failue(des: "TODO")
        return Promise<HiveFileHandle>(error: error)
    }

    override func fileHandle(atPath: String) -> Promise<HiveFileHandle>? {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        Promise<HiveFileHandle>? {
        let error = HiveError.failue(des: "TODO")
        return Promise<HiveFileHandle>(error: error)
    }
}
