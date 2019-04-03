import UIKit

@objc(HiveFile)
public class HiveFile: NSObject {
    
    public typealias HiveGetPathResponseHandler = (_ pathItem: String?, _ error: Error?) -> Void  // todo impatment with ODItem
    public typealias HiveGetParentPathResponseHandler = (_ parentPathItem: String?, _ error: Error?) -> Void // todo impatment with ODItem
    public typealias HiveGetParentResponseHandler = (_ parentItem: String?, _ error: Error?) -> Void // todo impatment with ODItem
    @objc public var drive: HiveDrive?
    @objc public var createdTimeDate: String{
        return ""
    }
    @objc public var lastModifiedTimeDateTime: String{
        return ""
    }
    @objc public var isFile: Bool{
        return false
    }
    @objc public var isDirectory: Bool {
        return false
    }
    @objc public func hiveFile(drive: HiveDrive) {
        self.drive = drive
    }
    
    /**
     * Create an file with specific pathname.
     *
     * @param drive The target drive to create a hive file.
     * @param pathname  The pathname.
     * @return An new hive file.
     * @throws Exception TODO
     */
    @objc(createFileWithDrive:pathname:error:)
    public static func createFile(drive: HiveDrive, pathname: String) throws -> HiveFile{
        return try drive.createFile(pathname: pathname)
    }
    
    @objc(getPath:)
    public func getPath(response: HiveGetPathResponseHandler) {
        // request to path
        
    }
    
    @objc(parentPath:)
    public func parentPath(response: HiveGetParentPathResponseHandler) {
        // request to parentPath
        
    }
    
    @objc(parent:)
    public func parent(response: HiveGetParentResponseHandler) {
        // request parent
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
    
    /**
     * Delete this file object.
     *
     * @throws Exception TODO
     */
    @objc(delete:)
    public func delete() throws {}
    
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
    
    //todo ----- 省略一个过滤方法
    
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
    
    //todo ----- 省略一个过滤方法
    
    /**
     * Create a directory.
     *
     * @param pathname The new pathname to create
     * @throws Exception TODO.
     */
    @objc(mkdir:error:)
    public func mkdir(pathname: String) throws {}
    
    /**
     * Create a directory along with all necessary parent directories.
     *
     * @param pathname The full pathname to create
     * @throws Exception TODO
     */
    @objc(mkdirs:error:)
    public func mkdirs(pathname: String) throws {}
    
    /**
     * Close hive file object.
     *
     * @throws Exception TODO
     */
    @objc(close:)
    public func close() throws {}
    
    // todo
    
}
