
import Foundation

class IPFSApis: NSObject {
    
    class func request(_ url: URLConvertible,
                       _ method: HTTPMethod = .post,
                       _ parameters: Parameters? = nil) -> HivePromise<JSON> {
        let promise: HivePromise = HivePromise<JSON> { resolver in
            Alamofire.request(url,
                              method: method,
                              parameters: parameters,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { dataResponse in
                    if dataResponse.response?.statusCode == 404 || dataResponse.response?.statusCode == nil {
                        let error = HiveError.failue(des: "Network timeouot.")
                        resolver.reject(error)
                        return
                    }
                    guard dataResponse.response?.statusCode == 200 else {
                        let json = JSON(dataResponse.result.value as Any)
                        let error = HiveError.failue(des: json["Message"].stringValue)
                        resolver.reject(error)
                        return
                    }
                    let json = JSON(dataResponse.result.value as Any)
                    resolver.fulfill(json)
                })
        }
        return promise
    }
    
    class func writeData(url: String, withData: Data) -> HivePromise<Hash> {
        let promise: HivePromise = HivePromise<Hash> { resolver in
            Alamofire.upload(multipartFormData: { data in
                data.append(withData, withName: "file", fileName: "data", mimeType: "text/plain")
            }, to: url, encodingCompletion: { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { dataResponse in
                        if dataResponse.response?.statusCode == 404 || dataResponse.response?.statusCode == nil {
                            // TODO: unvalid
                            let error = HiveError.failue(des: "Network timeouot.")
                            resolver.reject(error)
                            return
                        }
                        guard dataResponse.response?.statusCode == 200 else {
                            let json = JSON(dataResponse.result.value as Any)
                            let error = HiveError.failue(des: json["Message"].stringValue)
                            resolver.reject(error)
                            return
                        }
                        let hash = JSON(dataResponse.result.value as Any)["Hash"].stringValue
                        resolver.fulfill(Hash(hash))
                    })
                    break
                case .failure(let error):
                    resolver.reject(error)
                    break
                }
            })
        }
        return promise
    }
    
    class func read(_ url: URLConvertible,
                       _ method: HTTPMethod = .post,
                       _ parameters: Parameters? = nil) -> HivePromise<Data> {
        let promise: HivePromise = HivePromise<Data> { resolver in
            Alamofire.request(url,
                              method: method,
                              parameters: parameters,
                              encoding: URLEncoding.queryString,
                              headers: nil)
                .responseJSON(completionHandler: { dataResponse in
                    if dataResponse.response?.statusCode == 404 || dataResponse.response?.statusCode == nil {
                        let error = HiveError.failue(des: "Network timeouot.")
                        resolver.reject(error)
                        return
                    }
                    guard dataResponse.response?.statusCode == 200 else {
                        let json = JSON(dataResponse.result.value as Any)
                        let error = HiveError.failue(des: json["Message"].stringValue)
                        resolver.reject(error)
                        return
                    }
                    let data = dataResponse.data
                    guard data != nil else {
                        resolver.reject(HiveError.failue(des: "The data is nil."))
                        return
                    }
                    resolver.fulfill(data!)
                })
        }
        return promise
    }
}
