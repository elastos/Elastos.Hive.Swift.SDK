import Foundation

public class HiveFileInfo: NSObject {
    public final var fileId: String
    public var createdDateTime: String
    public var lastModifiedDateTime: String
    public var fileSystemInfo: Dictionary<String, Any>
    init(_ fileId: String) {
        self.fileId = fileId
        self.createdDateTime = ""
        self.lastModifiedDateTime = ""
        self.fileSystemInfo = [: ]
        super.init()
    }

    func infoValue(_ jsonData: JSON) {
        self.createdDateTime = jsonData["createdDateTime"].stringValue
        self.lastModifiedDateTime = jsonData["lastModifiedDateTime"].stringValue
        self.fileSystemInfo = jsonData["fileSystemInfo"].dictionaryValue
    }
}
