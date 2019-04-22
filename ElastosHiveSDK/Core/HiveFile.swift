import Foundation

@objc(HiveFile)
public class HiveFileHandle: NSObject {
    public var drive: HiveDriveHandle?
    public var createdDateTime: String?
    public var lastModifiedDateTime: String?
    public var isFile: Bool?
    public var isDirectory: Bool?
    public var id: String?

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

    public func pathName() -> String? {
        return nil
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
    @objc(updateDateTime:error:)
    public func updateDateTime(withValue newValue: String) throws {}

    /**
     * Delete this file object.
     *
     * @throws Exception TODO
     */
    @objc(deleteItem:)
    public func deleteItem() throws {}

    /**
     * Close hive file object.
     *
     * @throws Exception TODO
     */
    @objc(closeItem:)
    public func closeItem() throws {}
}

extension HiveFileHandle {
    /**
     * Copy the item to another address.
     *
     * @param newPath The copy-to pathname.
     * @throws Exception TODO
     */
    @objc(copyTo:error:)
    public func copyFileTo(newPath: String) throws {
    }

    /**
     * Copy the item to another item.
     *
     * @param newFile The new Hive File object.
     * @throws Exception TODO
     */
    @objc(copyToNewFile:error:)
    public func copyFileTo(newFile: HiveFileHandle) throws {
    }

    /**
     * Rename the item name to another name.
     *
     * @param newPath The new file path to rename with.
     * @throws Exception TODO
     */
    @objc(renameToNewPath:error:)
    public func renameFileTo(newPath: String) throws {

    }

    /**
     * Rename the item to new item.
     *
     * @param newFile The new Hive File to rename with.
     * @throws Exception TODO
     */
    @objc(renameToNewFile:error:)
    public func renameFileTo(newFile: HiveFileHandle) throws {
    }
}

extension HiveFileHandle {
    /**
     * List all file objects under this directory.
     *
     * @return The array of hive file objects.
     * @throws Exception TODO
     */
    @objc(list:)
    public func list() throws -> [HiveFileHandle] {
        return [HiveFileHandle] ()
    }

    /**
     * List all file objects under this directory.
     *
     * @return The array of hive file objects.
     * @throws Exception TODO
     */
    @objc(listFiles:)
    public func listFiles() throws -> [HiveFileHandle] {
        let files: [HiveFileHandle] = try list()
        return files
    }

    /**
     * Create a directory.
     *
     * @param pathname The new pathname to create
     * @throws Exception TODO.
     */
    @objc(mkdir:error:)
    public func mkdir(pathname: String) throws {
    }

    /**
     * Create a directory along with all necessary parent directories.
     *
     * @param pathname The full pathname to create
     * @throws Exception TODO
     */
    @objc(mkdirs:error:)
    public func mkdirs(pathname: String) throws {
    }
}
