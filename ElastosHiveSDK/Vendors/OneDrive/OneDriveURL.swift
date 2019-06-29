import Foundation

enum ONEDRIVE_SUB_Url: String {
    case ONEDRIVE_AUTHORIZE   = "authorize"
    case ONEDRIVE_LOGOUT      = "/logout"
    case ONEDRIVE_TOKEN       = "/token"
}

class OneDriveURL {
    internal static let AUTH = "https://login.microsoftonline.com/common/oauth2/v2.0"
    internal static let API  = "https://graph.microsoft.com/v1.0/me/drive"

    private let pathName: String
    private let extName : String?

    convenience init(_ pathName: String) {
        self.init(pathName, nil)
    }

    init(_ pathName: String, _ extName: String?) {
        self.pathName = pathName
        self.extName  = extName
    }

    func compose() -> String {
        if pathName == "/" && extName == nil {
            return OneDriveURL.API + "/root"
        }

        if pathName == "/" && extName != nil {
            return OneDriveURL.API + "/root/\(extName!)"
        }

        if pathName != "/" && extName == nil {
            let path = pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            return OneDriveURL.API + "/root:\(path)"
        }

        let path = pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        return OneDriveURL.API + "/root:\(path):/\(extName!)"
    }
}
