
import Foundation
import Swifter

@objc(OneDriveAuthHelper)
class OneDriveAuthHelper: AuthHelper {
    private var authInfo: AuthInfo?
    private var appId: String
    private var scopes: String
    private var redirectUrl: String
    private var authCode: String?
    let server = HttpServer()

    
    public init(_ appId: String, _ scopes: Array<String>, _ redirectUrl: String) {
        self.appId = appId
        self.scopes = scopes.joined(separator: " ")
        self.redirectUrl = redirectUrl
    }

    public func login(_ hiveError: @escaping (_ error: HiveError?) -> Void) {
        if (!hasLogin()) {
            getAuthCode { (authCode, error) in
                guard error == nil else {
                    hiveError(error)
                    return
                }
                self.authCode = authCode
                self.requestAccessToken(authorCode: authCode!)
                self.authCode = nil
                self.server.stop()
            }
        }
    }

    private func getAuthCode(_ authCode: @escaping (_ authCode: String?, _ error: HiveError?) -> Void) {
        do {
            server[""] = { request in
                guard request.queryParams.count > 0 || request.queryParams[0].0 != "code" else {
                     authCode(nil, .failue(des: "authCode获取失败"))
                    return HttpResponse.ok(.json("nil" as AnyObject))
                }
                let authJson = request.queryParams[0]
                authCode(authJson.1,nil)
                return HttpResponse.ok(.json("nil" as AnyObject))
            }
            try server.start(44316)
        } catch {
            authCode(nil,(error as! HiveError))
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
