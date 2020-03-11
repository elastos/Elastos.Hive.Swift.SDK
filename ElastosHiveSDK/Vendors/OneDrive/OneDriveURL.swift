
import Foundation

class OneDriveURL {
    
    private var _path: String
    
    init(forPath: String) {
        _path = "\(forPath)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    func dirAndFileInfo() -> String {
        return ONE_DRIVE_API_BASE_URL + APP_ROOT + ":\(_path)"
    }
    
    func deleteItem() -> String {
        return ONE_DRIVE_API_BASE_URL + APP_ROOT + ":\(_path)"
    }
    
    class func children() -> String {
        return ONE_DRIVE_API_BASE_URL + APP_ROOT + ":\(FILES_ROOT_PATH):/children"
    }
    
    func read() -> String {
        return ONE_DRIVE_API_BASE_URL + APP_ROOT + ":\(_path):/content"
    }
    
    func write() -> String {
        return ONE_DRIVE_API_BASE_URL + APP_ROOT + ":\(_path):/content"
    }
    
    func createUploadSession() -> String {
        return ONE_DRIVE_API_BASE_URL + APP_ROOT + ":\(_path):/createUploadSession"
    }
    
   class func acquireAuthCode(_ param: String) -> String {
        return ONE_DRIVE_AUTH_BASE_URL + AUTHORIZE + "?\(param.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
    }
    
    class func token() -> String {
        return ONE_DRIVE_AUTH_URL + TOKEN
    }
    
    func logout() -> String {
        return ONE_DRIVE_AUTH_URL + LOGOUT + "?post_logout_redirect_uri=\(_path)"
    }
}
