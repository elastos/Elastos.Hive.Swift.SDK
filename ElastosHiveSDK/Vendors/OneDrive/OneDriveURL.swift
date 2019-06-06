import Foundation

enum ONEDRIVE_SUB_Url: String {
    case ONEDRIVE_AUTHORIZE   = "authorize"
    case ONEDRIVE_LOGOUT      = "/logout"
    case ONEDRIVE_TOKEN       = "/token"
}

class OneDriveURL {
    internal static let AUTH = "https://login.microsoftonline.com/common/oauth2/v2.0"
    internal static let API  = "https://graph.microsoft.com/v1.0/me/drive"
}
