import Foundation

public class HiveDirectoryInfo: NSObject {
    public final var dirId: String
    public var createdDateTime: String
    public var lastModifiedDateTime: String

    init(_ dirId: String) {
        self.dirId = dirId
        self.createdDateTime = ""
        self.lastModifiedDateTime = ""
        super.init()
    }

    func installValue(_ jsonData: JSON) {
        self.createdDateTime = jsonData["createdDateTime"].stringValue
        self.lastModifiedDateTime = jsonData["lastModifiedDateTime"].stringValue
    }
}
