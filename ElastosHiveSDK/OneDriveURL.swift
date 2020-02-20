
import Foundation

class OneDriveURL {
    
    private var _path: String
    init(_ path: String) {
       _path = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    func dirAndFileInfo() -> String {
        return ONE_DRIVE_API_BASE_URL + APP_ROOT + ":/\(_path)"
    }
    
    func deleteItem() -> String {
        return ONE_DRIVE_API_BASE_URL + APP_ROOT + ":\(_path)"
    }
    
    func children() -> String {
        return ONE_DRIVE_API_BASE_URL + APP_ROOT + ":\(_path):/children"
    }
    
    func read() -> String {
        return ONE_DRIVE_API_BASE_URL + APP_ROOT + ":\(_path):/content"
    }
    
    func write() -> String {
        return ONE_DRIVE_API_BASE_URL + APP_ROOT + ":\(_path):/content"
    }
    
    func acquireAuthCode() -> String {
        return ONE_DRIVE_AUTH_BASE_URL + AUTHORIZE + "?\(_path)"
    }
    
    func token() -> String {
        return ONE_DRIVE_AUTH_URL + TOKEN
    }
    
    func logout() -> String {
        return ONE_DRIVE_AUTH_URL + LOGOUT + "?post_logout_redirect_uri=\(_path)"
    }
}
