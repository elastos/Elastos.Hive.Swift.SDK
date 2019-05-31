import Foundation

public enum DriveState {
    case normal
    case nearing
    case critical
    case exceeded
}

public class HiveDriveInfo: NSObject {
    public var driveId: String
    public var capacity: String
    public var remaining: String
    public var deleted: String
    public var fileCount: String
    public var state: String
    public var lastModifiedDateTime: String
    public var ddescription: String
    public var driveState: DriveState

    init(_ driveId: String) {
        self.driveId = driveId
        self.capacity = ""
        self.remaining = ""
        self.deleted = ""
        self.fileCount = ""
        self.state = ""
        self.lastModifiedDateTime = ""
        self.ddescription = ""
        self.driveState = .normal
        super.init()
    }

    func installValue(_ jsonData: JSON) {
        let quota = JSON(jsonData["quota"])
        self.capacity = quota["capacity"].stringValue
        self.remaining = quota["remaining"].stringValue
        self.deleted = quota["deleted"].stringValue
        self.lastModifiedDateTime = jsonData["lastModifiedDateTime"].stringValue
        let folder = JSON(jsonData["folder"])
        self.fileCount = folder["childCount"].stringValue
        self.ddescription = ""
        self.driveState = .normal
        let state = jsonData["state"].stringValue
        self.state = state
        if state == "normal" {
            self.driveState = .normal
        }else if state == "nearing" {
            self.driveState = .nearing
        }else if state == "critical" {
            self.driveState = .critical
        }else if state == "exceeded" {
            self.driveState = .exceeded
        }
    }
}
