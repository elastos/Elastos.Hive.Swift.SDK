import Foundation

public typealias HiveFileObjectsListResponseHandler = (_ files: [HiveFileHandle]?, _ error: HiveError?) -> Void

@objc(HiveFile)
public class HiveFileHandle: NSObject {
    public var drive: HiveDriveHandle?
    public var createdDateTime: String?
    public var lastModifiedDateTime: String?
    public var isFile: Bool?
    public var isDirectory: Bool?
    public var id: String?
    public var pathName: String?
    public var name: String?
    public var rootPath: String?
    public var parentId: String?
    public var parentPath: String?
    public var driveId: String?
    public var fileSystemInfo: Dictionary<AnyHashable, Any>?
    public var parentReference: Dictionary<AnyHashable, Any>?
    public var createDateTime: String?

    /**
     * Create an file with specific pathname.
     *
     * @param drive The target drive to create a hive file.
     * @param pathname  The pathname.
     * @return An new hive file.
     * @throws Exception TODO
     */
    public func createFile(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        return nil
    }

    public func fileHandle(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        return nil
    }

    public static func createFile(atPath: String, _ contents: Data, _ withResult: @escaping (HiveFileObjectCreationResponseHandler)) {
        // TODO;
    }

    public func parentHandle() -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

   public func moveTo(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        return nil
    }

    /**
     * Delete this file object.
     *
     * @throws Exception TODO
     */

    public func deleteItem() -> CallbackFuture<Bool>? {
        return nil
    }

    /**
     * Close hive file object.
     *
     */
    func close() {
    }

    public func readData() -> CallbackFuture<HiveResult<Data>>? {
        return nil
    }

    public func writeData(withData: Data) -> CallbackFuture<HiveResult<Bool>>? {
        return nil
    }

    /**
     * Copy the item to another address.
     *
     * @param newPath The copy-to pathname.
     * @throws Exception TODO
     */
    public func copyTo(atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        return nil
    }

    /**
     * Rename the item name to another name.
     *
     * @param newPath The new file path to rename with.
     * @throws Exception TODO
     */
    public func renameFileTo(_ atPath: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        return nil
    }

    /**
     * Rename the item to new item.
     *
     * @param newFile The new Hive File to rename with.
     * @throws Exception TODO
     */
    public func renameFileTo(newFile: HiveFileHandle) throws {
    }

    /**
     * List all file objects under this directory.
     *
     * @return The array of hive file objects.
     * @throws Exception TODO
     */
    public func list() -> CallbackFuture<HiveResult<[HiveFileHandle]>>? {
        return nil
    }

}
