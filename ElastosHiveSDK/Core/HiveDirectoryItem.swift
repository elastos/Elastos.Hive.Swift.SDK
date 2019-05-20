import Foundation
import PromiseKit

public protocol HiveDirectoryItem {
    func createDirectory(withPath: String) -> Promise<HiveDirectoryHandle>?
    func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> Promise<HiveDirectoryHandle>?

    func directoryHandle(atPath: String) -> Promise<HiveDirectoryHandle>?
    func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> Promise<HiveDirectoryHandle>?

    func createFile(withPath: String) -> Promise<HiveFileHandle>?
    func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> Promise<HiveFileHandle>?

    func fileHandle(atPath: String) -> Promise<HiveFileHandle>?
    func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> Promise<HiveFileHandle>?
}
