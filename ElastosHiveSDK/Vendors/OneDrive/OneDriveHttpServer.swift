import Foundation


enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}


class OneDriveHttpServer: NSObject {

    public typealias requestRespons = (_ response: Dictionary<String, Any>?, _ error: HiveError?) -> Void

    class func post(_ url: String, _ param: Dictionary<String, Any>?, _ header: Dictionary<String, Any>?, _ responseHandle: @escaping requestRespons) {
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpMethod = RequestMethod.post.rawValue
        if header != nil {
            if !(header!.isEmpty) {
                for (key, value) in header! {
                    let accesstoken: String = value as! String
                    request.setValue("bearer \(accesstoken)", forHTTPHeaderField: key)
                }
            }
            request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            do{
                request.httpBody = try JSONSerialization.data(withJSONObject: param as Any, options: .prettyPrinted)
            }catch{
            }
        }
        else {
            request.httpBody = param!.queryString.data(using: String.Encoding.utf8)
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                responseHandle(nil, (error as! HiveError))
                return
            }
            do {
                guard data != nil else {
                    responseHandle(nil, .failue(des: "response data is empty"))
                    return
                }
                let responseJson: Dictionary<String, Any> = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary
                guard !responseJson.isEmpty else {
                    responseHandle(nil, .failue(des: "response data is empty"))
                    return
                }
                    if (responseJson["error_description"] != nil || responseJson["error"] != nil) {
                        responseHandle(nil,.failue(des: String(data: data!, encoding: String.Encoding.utf8)!))
                        return
                    }
                    responseHandle(responseJson, nil)
                } catch {
                    responseHandle(nil, (error as! HiveError))
                }
            }
            task.resume()
        }

    class func get(_ url: String, _ responseHandle: @escaping requestRespons) {
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = RequestMethod.get.rawValue
        let keychain: KeychainSwift = KeychainSwift() // todo  take frome keychain
        let accesstoken: String? = keychain.get(ACCESS_TOKEN)
        guard accesstoken != nil else {
            responseHandle(nil, .failue(des: "access_token obtain faild"))
            return
        }
        request.setValue("bearer \(accesstoken!)", forHTTPHeaderField: HEADER_AUTHORIZATION)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                responseHandle(nil, (error as! HiveError))
                return
            }
            do{
                guard data != nil else {
                    responseHandle(nil, .failue(des: "response data is empty"))
                    return
                }
                let responseJson: Dictionary<String, Any> = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary
                guard !responseJson.isEmpty else {
                    responseHandle(nil, .failue(des: "response data is empty"))
                    return
                }
                guard responseJson["error"] == nil else {
                    responseHandle(nil, .failue(des: String(data: data!, encoding: String.Encoding.utf8)!))
                    return
                }
                responseHandle(responseJson,nil)
            }catch {
                responseHandle(nil, (error as! HiveError))
            }
        }
        task.resume()
    }
}
