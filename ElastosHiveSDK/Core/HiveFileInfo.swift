import Foundation

public class HiveFileInfo: NSObject {
    public final var fileId: String?

    init(_ fileId: String) {
        self.fileId = fileId
        super.init()
    }
}
