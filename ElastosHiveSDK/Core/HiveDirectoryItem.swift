import Foundation
import PromiseKit

public protocol HiveDirectoryItem {
    func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle>?
    func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>?

    func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle>?
    func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>?

    func createFile(withPath: String) -> HivePromise<HiveFileHandle>?
    func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>?

    func fileHandle(atPath: String) -> HivePromise<HiveFileHandle>?
    func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>?
}
