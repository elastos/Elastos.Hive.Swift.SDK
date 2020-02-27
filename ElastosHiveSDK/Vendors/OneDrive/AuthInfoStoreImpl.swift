
class AuthInfoStoreImpl: Persistent {
    private var path: String
    init(_ path: String) {
        self.path = path + "/" + ONEDRIVE_CONFIG
    }
    
    func parseFrom() -> Dictionary<String, Any> {
        let fileManager = FileManager.default
        let exist: Bool = fileManager.fileExists(atPath: path)
        if (exist) {
            do {
                let readHandler = FileHandle(forReadingAtPath: path)!
                let data = readHandler.readDataToEndOfFile()
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] ?? [: ]
                return json
            }
            catch {
                print(error)
            }
        }
        return [: ]
    }
    
    func upateContent(_ json: Dictionary<String, Any>) {
        let fileManager = FileManager.default
        let exist: Bool = fileManager.fileExists(atPath: path)
        do {
            if !exist {
                let perpath = path.prefix(path.count - "/onedrive.json".count)
                try fileManager.createDirectory(atPath: String(perpath), withIntermediateDirectories: true, attributes: nil)
                fileManager.createFile(atPath: path, contents: nil, attributes: nil)
            }
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            try data.write(to: URL(fileURLWithPath: path))
        } catch {
            print(error)
        }
    }
}
