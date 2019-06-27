import Foundation
import PromiseKit

protocol DirectoryItem {

    /*
    // for drive
    func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle>
    func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>

    func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle>
    func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>

    func createFile(withPath: String) -> HivePromise<HiveFileHandle>
    func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>

    func fileHandle(atPath: String) -> HivePromise<HiveFileHandle>
    func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>

    // for directory
    func createDirectory(withName: String) -> HivePromise<HiveDirectoryHandle>
    func createDirectory(withName: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>

    func directoryHandle(atName: String) -> HivePromise<HiveDirectoryHandle>
    func directoryHandle(atName: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>

    func createFile(withName: String) -> HivePromise<HiveFileHandle>
    func createFile(withName: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>

    func fileHandle(atName: String) -> HivePromise<HiveFileHandle>
    func fileHandle(atName: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>
 */
}

extension DirectoryItem{
    public func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }
    public func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    public func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle>{
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }
    public func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    public func createFile(withPath: String) -> HivePromise<HiveFileHandle>{
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }
    public func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }

    public func fileHandle(atPath: String) -> HivePromise<HiveFileHandle>{
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }
    public func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }

    public func createDirectory(withName: String) -> HivePromise<HiveDirectoryHandle>{
        return createDirectory(withName: withName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }
    public func createDirectory(withName: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    public func directoryHandle(atName: String) -> HivePromise<HiveDirectoryHandle>{
        return directoryHandle(atName: atName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }
    public func directoryHandle(atName: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    public func createFile(withName: String) -> HivePromise<HiveFileHandle>{
        return createFile(withName: withName, handleBy: HiveCallback<HiveFileHandle>())
    }
    public func createFile(withName: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }

    public func fileHandle(atName: String) -> HivePromise<HiveFileHandle>{
        return fileHandle(atName: atName, handleBy: HiveCallback<HiveFileHandle>())
    }
    public func fileHandle(atName: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }
}
