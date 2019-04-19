import Foundation

@objc(OneDriveFile)
public class OneDriveFile: HiveFile {
    
    @objc public var pathname: String?

    public override func getPath() -> String? {
        return pathname
    }

    public override func parentPath() -> String? {
        return pathname
    }

    public override func parent(_ responseHandle: @escaping (HiveFile.hiveFileResponse)) {
        let pathName: String = parentPath()!
        super.drive?.getFile(pathName, { (hiveFile, error) in
            responseHandle(hiveFile, error)
        })
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
