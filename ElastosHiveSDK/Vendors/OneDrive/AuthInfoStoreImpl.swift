
class AuthInfoStoreImpl: Persistent {
    private var path: String
    init(_ path: String) {
        self.path = path + "/" + ONEDRIVE_CONFIG
    }
    
    func parseFrom() -> Dictionary<String, Any> {
        
        return [: ]
    }
    
    func upateContent(_ json: Dictionary<String, Any>) {
        let fileManager = FileManager.default
        let exist: Bool = fileManager.fileExists(atPath: path)
        if !exist {
            fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        }
        //todo: seve
    }
}
