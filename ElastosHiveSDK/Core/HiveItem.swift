

import UIKit

public class HiveItem: NSObject {

    public var id: String
    public var createdDateTime: String
    public var lastModifiedDateTime: String
    public var isFolder: Bool
    public var fileSystemInfo: Dictionary<String, Any>

    public override init() {
        id = ""
        createdDateTime = ""
        lastModifiedDateTime = ""
        isFolder = false
        fileSystemInfo = [: ]
    }

    func installValue(_ jsonData: JSON) {
        self.createdDateTime = jsonData["createdDateTime"].stringValue
        self.lastModifiedDateTime = jsonData["lastModifiedDateTime"].stringValue
        self.fileSystemInfo = jsonData["fileSystemInfo"].dictionaryValue
        let folder = jsonData["folder"].stringValue 
        if folder != "" {
            isFolder = true
        }
    }
}
