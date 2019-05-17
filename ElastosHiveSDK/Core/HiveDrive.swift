import Foundation
import PromiseKit

public struct HiveResult<T> {
    var handle: T
}

public typealias HiveFileObjectCreationResponseHandler = (_ file: HiveFileHandle?, _ error: HiveError?) -> Void
public typealias CallbackFuture = Promise


@objc(HiveDrive)
public class HiveDriveHandle: NSObject {
    func driveType() -> DriveType {
        return .local
    }

    public func driveInfo() -> HiveDriveInfo? {
        //TODO
        return nil
    }

    public func rootDirectoryHandle() -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    // TODO
//    public func rootDirectoryHandle(resultHandler: @escaping Callback<HiveResult<HiveDirectoryHandle>>) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>

    public func createDirectory(atPath: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    public func directoryHandle(atPath: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    // TODO
//    func createDirectory(atPath: String, resultHandler: @escaping Callback<HiveResult<HiveDirectoryHandle>>) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>

    public func createFile(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        return nil
    }

    // TODO
//    func directoryHandle(atPath: String, resultHanler: @escaping Callback<HiveResult<HiveDirectoryHandle>>) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>

    public func fileHandle(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        return nil
    }

}
