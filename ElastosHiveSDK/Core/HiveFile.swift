import Foundation

@objc(HiveFile)
public class HiveFile: NSObject {
    public typealias hiveFileResponse = (_ hiveFile: HiveFile?, _ error: Error?) -> Void
    public var drive: HiveDrive?
    public var createdDateTime: String?
    public var lastModifiedDateTime: String?
    public var isFile: Bool?
    public var isDirectory: Bool?
    
    /**
     * Create an file with specific pathname.
     *
     * @param drive The target drive to create a hive file.
     * @param pathname  The pathname.
     * @return An new hive file.
     * @throws Exception TODO
     */
    public static func createFile(_ pathname: String, _ responseHandle: @escaping (hiveFileResponse)) {
//        return try drive.createFile(pathname: pathname)
    }

    public func getPath() -> String? {
        return nil
    }

    public func parentPath() -> String? {
        return nil
    }

    public func parent(_ responseHandle: @escaping (hiveFileResponse)) {
        
    }
    
    /**
     * Update date and time of this item.
     *
     * @param newDateTime The updated date and time.
     * @throws Exception TODO
     */
    @objc(updateDateTime:error:)
    public func updateDateTime(newDateTime: String) throws {}
    
    /**
     * Delete this file object.
     *
     * @throws Exception TODO
     */
    @objc(delete:)
    public func delete() throws {}

    /**
     * Close hive file object.
     *
     * @throws Exception TODO
     */
    @objc(close:)
    public func close() throws {}
}

extension HiveFile {
    /**
     * Copy the item to another address.
     *
     * @param newPath The copy-to pathname.
     * @throws Exception TODO
     */
    @objc(copyTo:error:)
    public func copyTo(newPath: String) throws {
    }

    /**
     * Copy the item to another item.
     *
     * @param newFile The new Hive File object.
     * @throws Exception TODO
     */
    @objc(copyToNewFile:error:)
    public func copyTo(newFile: HiveFile) throws {
    }

    /**
     * Rename the item name to another name.
     *
     * @param newPath The new file path to rename with.
     * @throws Exception TODO
     */
    @objc(renameToNewPath:error:)
    public func renameTo(newPath: String) throws {

    }

    /**
     * Rename the item to new item.
     *
     * @param newFile The new Hive File to rename with.
     * @throws Exception TODO
     */
    @objc(renameToNewFile:error:)
    public func renameTo(newFile: HiveFile) throws {
    }
}

extension HiveFile {
    /**
     * List all file objects under this directory.
     *
     * @return The array of hive file objects.
     * @throws Exception TODO
     */
    @objc(list:)
    public func list() throws -> [HiveFile] {
        return [HiveFile] ()
    }

    /**
     * List all file objects under this directory.
     *
     * @return The array of hive file objects.
     * @throws Exception TODO
     */
    @objc(listFiles:)
    public func listFiles() throws -> [HiveFile] {
        let files: [HiveFile] = try list()
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
