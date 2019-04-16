import Foundation

@objc(OneDriveAuthHelper)
class OneDriveAuthHelper: AuthHelper {
    private var authInfo: AuthInfo?
    private var appId: String
    private var scopes: String
    private var redirectUrl: String
    private var authCode: String?
    
    public init(_ appId: String, _ scopes: Array<String>, _ redirectUrl: String) {
        self.appId = appId
        self.scopes = scopes.joined(separator: " ")
        self.redirectUrl = redirectUrl
    }
    
    public func login() throws {
        if(!hasLogin()){
            let authViewController:AuthWebViewController = AuthWebViewController()
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController
            rootViewController?.present(authViewController, animated: true, completion: nil)
            authViewController.loadRequest(appId, redirectUrl, "code", scopes)
            authViewController.responseHandle = { ( response, error ) -> Void in
                let json: Dictionary = (response?.queryDictionary)!
                let code = json["code"]
                guard code?.count ?? 0 > 0 else {
                    return
                }
                self.authCode = code
                self.requestAccessToken(authorCode: self.authCode!)
            }
        }
        if(isExpired()){
            try? refreshAccessToken()
        }
    }
    
    private func requestAccessToken(authorCode: String) {
        
        let params: Dictionary = ["client_id" : appId,
                                  "code" : authorCode,
                                  "grant_type" : "authorization_code",
                                  "redirect_uri" : redirectUrl]
        var request: URLRequest = URLRequest(url: URL(string: TOKEN_URL)!)
        request.httpMethod = "POST"
        request.httpBody = params.queryString.data(using: String.Encoding.utf8)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
            } else {
                do {
                    let responseJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    print(responseJson)
                } catch let error {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    private func refreshAccessToken() throws {
        // todo
    }
    
    private func hasLogin() -> Bool {
        if(authInfo != nil){
            return true
        }
        return false
    }
    
    private func isExpired() -> Bool {
        //        return (authInfo?.isExpired())!
        return false
    }
    
    override public func checkExpired() throws {
        // todo
    }
}
