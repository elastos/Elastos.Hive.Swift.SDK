import Foundation

public class HiveDirectoryInfo: NSObject {
    public final var dirId: String

    init(_ dirId: String) {
        self.dirId = dirId
        super.init()
    }
}
