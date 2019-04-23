import Foundation

@objc(HiveFile)
public class HiveFileHandle: NSObject {
    public var drive: HiveDriveHandle?
    public var createdDateTime: String?
    public var lastModifiedDateTime: String?
    public var isFile: Bool?
    public var isDirectory: Bool?
    public var id: String?
    public var pathName: String?
    public var driveId: String?
    public var fileSystemInfo: Dictionary<AnyHashable, Any>?
    public typealias HandleResulr = (_ result: Bool?, _ error: HiveError?) -> Void
    public typealias HandleResulrWithFile = (_ file: HiveFileHandle?, _ error: HiveError?) -> Void
    public typealias HandleResulrWithFiles = (_ files: [HiveFileHandle]?, _ error: HiveError?) -> Void

    /**
     * Create an file with specific pathname.
     *
     * @param drive The target drive to create a hive file.
     * @param pathname  The pathname.
     * @return An new hive file.
     * @throws Exception TODO
     */
    public static func createFile(atPath: String, _ withResult: @escaping (HiveFileObjectCreationResponseHandler)) {
        // return try drive.createFile(pathname: pathname)
    }

    public static func createFile(atPath: String, _ contents: Data, _ withResult: @escaping (HiveFileObjectCreationResponseHandler)) {
        // TODO;
    }

    public func parentPathName() -> String? {
        return nil
    }

    public func parentHandle(withResult result: @escaping (HiveFileObjectCreationResponseHandler)) {
    }

    /**
     * Update date and time of this item.
     *
     * @param newDateTime The updated date and time.
     * @throws Exception TODO
     */
    public func updateDateTime(withValue newValue: String) throws {}

    /**
     * Delete this file object.
     *
     * @throws Exception TODO
     */
    public func deleteItem(result: @escaping HandleResulr) throws {}

    /**
     * Close hive file object.
     *
     * @throws Exception TODO
     */
    public func closeItem() throws {}

    /**
     * Copy the item to another address.
     *
     * @param newPath The copy-to pathname.
     * @throws Exception TODO
     */
    public func copyFileTo(newPath: String, result: @escaping HandleResulr) throws {
    }

    /**
     * Copy the item to another item.
     *
     * @param newFile The new Hive File object.
     * @throws Exception TODO
     */
    public func copyFileTo(newFile: HiveFileHandle, result: @escaping HandleResulr) throws {
    }

    /**
     * Rename the item name to another name.
     *
     * @param newPath The new file path to rename with.
     * @throws Exception TODO
     */
    public func renameFileTo(newPath: String, result: @escaping HandleResulr) throws {

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
    public func list(result: @escaping HandleResulrWithFiles) throws {
    }

    /**
     * List all file objects under this directory.
     *
     * @return The array of hive file objects.
     * @throws Exception TODO
     */
    public func listFiles() throws -> [HiveFileHandle]? {
        return nil
    }

    /**
     * Create a directory.
     *
     * @param pathname The new pathname to create
     * @throws Exception TODO.
     */
    public func mkdir(pathname: String, result: @escaping HandleResulrWithFile) throws {
    }

    /**
     * Create a directory along with all necessary parent directories.
     *
     * @param pathname The full pathname to create
     * @throws Exception TODO
     */
    public func mkdirs(pathname: String) throws {
    }
}
