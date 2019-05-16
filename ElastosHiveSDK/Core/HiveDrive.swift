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

    public func rootDirectoryHandle() -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    public func createDirectory(atPath: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    public func createFile(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        return nil
    }

    public func directoryHandle(atPath: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }
    
    public func fileHandle(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        return nil
    }

}
