import UIKit

@objc(OnedriveFile)
public class OnedriveFile: HiveFile {
    
    @objc public var pathname: String?
    
    override public var createdTimeDate: String{
        return ""
    }
    override public var lastModifiedTimeDateTime: String{
        return ""
    }
    override public var isFile: Bool{
        return false
    }
    override public var isDirectory: Bool{
        return false
    }
    
    public override func getPath(response: (String?, Error?) -> Void) {
        
    }
    
    public override func parent(response: (String?, Error?) -> Void) {
        
    }
    
    public override func parentPath(response: (String?, Error?) -> Void) {
        
    }
    
    override public func updateDateTime(newDateTime: String) throws {
        
    }
    
    override public func copyTo(newPath: String) throws {
    }
    
    override public func copyTo(newFile: HiveFile) throws {
        
    }
    
    override public func renameTo(newPath: String) throws {
        
    }
    
    override public func renameTo(newFile: HiveFile) throws {
        
    }
    
    override public func delete() throws {
        
    }
    
    override public func list() throws -> [HiveFile] {
        return [HiveFile]()
    }
    
    override public func mkdir(pathname: String) throws {
        
    }
    
    override public func mkdirs(pathname: String) throws {
        
    }
    
    override public func close() throws {
        
    }
}
