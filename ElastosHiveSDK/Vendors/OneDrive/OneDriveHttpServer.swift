
import UIKit

class OneDriveHttpServer: NSObject {

    public typealias requestRespons = (_ response: Dictionary<String, Any>?, _ error: HiveError?) -> Void

    class func post(_ url: String, _ param: Dictionary<String, Any>, _ responseHandle: @escaping requestRespons) {
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = param.queryString.data(using: String.Encoding.utf8)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                responseHandle(nil, (error as! HiveError))
                return
            }
            do {
                guard data != nil else {
                    responseHandle(nil, .failue(des: "返回数据为空"))
                    return
                }
                let responseJson: Dictionary<String, Any> = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary
                guard !responseJson.isEmpty else {
                    responseHandle(nil, .failue(des: "返回数据为空"))
                    return
                }
                guard responseJson["error_description"] == nil else {
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
        request.httpMethod = "GET"
        let keychain: KeychainSwift = KeychainSwift() // todo  take frome keychain
        let accesstoken: String = keychain.get("access_token")!

        request.setValue("bearer \(accesstoken)", forHTTPHeaderField: HIVE_API_HEADER_AUTHORIZATION)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                responseHandle(nil, (error as! HiveError))
                return
            }
            do{
                guard data != nil else {
                    responseHandle(nil, .failue(des: "返回数据为空"))
                    return
                }
                let responseJson: Dictionary<String, Any> = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary
                guard !responseJson.isEmpty else {
                    responseHandle(nil,.failue(des: "返回数据为空"))
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
