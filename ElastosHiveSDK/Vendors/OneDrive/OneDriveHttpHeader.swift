import Foundation

class OneDriveHttpHeader {
    internal static let Authorization   = "Authorization"
    internal static let ContentType     = "Content-Type"
    internal static let ContentTypeValue    = "application/x-www-form-urlencoded"

    static func bearerValue(_ authHelper: AuthHelper) -> String {
        return "TODO"
    }
}
