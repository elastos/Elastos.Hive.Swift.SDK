import Foundation

@objc(OneDriveFile)
class OneDriveFile: HiveFileHandle {
    @objc var _pathname: String?

    override func pathName() -> String? {
        return _pathname
    }

    public override func parentPathName() -> String? {
        return _pathname
    }

    override func parentHandle(withResult resultHandler: @escaping (HiveFileObjectCreationResponseHandler)) {
        //let path: String = parentPathName()!
        //super.drive?.getFileHandle(atPath path) { (file, error) in
        //    resultHandler(file, error)
        //}
    }

    override func updateDateTime(withValue newValue: String) throws {
        // TODO
    }

    override func copyFileTo(newPath: String) throws {
        // TODO
    }

    override func copyFileTo(newFile: HiveFileHandle) throws {
        // TODO
    }
    
    override func renameFileTo(newPath: String) throws {
        // TODO
    }
    
    override func renameFileTo(newFile: HiveFileHandle) throws {
        // TODO
    }
    
    override func deleteItem() throws {
        // TODO
    }

    override func closeItem() throws {
        // TODO
    }
    
    override func list() throws -> [HiveFileHandle] {
        return [HiveFileHandle]()
    }
    
    override func mkdir(pathname: String) throws {
        // TODO
    }
    
    override func mkdirs(pathname: String) throws {
        // TODO
    }
}
