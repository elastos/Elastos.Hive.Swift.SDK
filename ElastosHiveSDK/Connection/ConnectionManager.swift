/*
* Copyright (c) 2019 Elastos Foundation
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import Foundation
import ObjectMapper

extension DataRequest {
    
    func execute() -> HiveResponse? {
        // TODO
        return nil
    }

        
    func execute<T: Mappable>(options: JSONSerialization.ReadingOptions = .allowFragments, _ resultType: T.Type) throws -> T {
        let response1 = response(responseSerializer: JSONResponseSerializer(options: options))
        switch response1.result {
        case .success(let re):
            let json = re as! [String : Any]
            if json["_status"] as! String != "OK" {
                let errorObject = JSON(json)
                let code = errorObject["_error"] ["code"];
                let message = errorObject["_error"] ["message"];
                throw HiveError.hiveSdk(message: "get error from server: error code = \(code), message = \(message)")
            }
            
            let result = T(JSON: re as! [String : Any])!
//            try result.checkResponseVaild()
            return result
        case .failure(let error):
            let e = error
            switch e {
            case .responseSerializationFailed(_):
                var des = ""
                if response1.data != nil {
                    des = String(data: response1.data!, encoding: .utf8) ?? ""
                }
                let err = HiveError.responseSerializationFailed(des: des)
                throw err
            default: break
            }
            throw error
        }
    }
}

extension ConnectionManager {
    public func createCollection(_ collection: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/collections/\(collection)"
        return try self.createDataRequest(url, .put, nil)
    }
    
    public func deleteCollection(_ collection: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/\(collection)"
        return try self.createDataRequest(url, .delete, nil)
    }
    
    public func insert(_ collection: String, _ params: InsertParams) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/collection/\(collection)"
        return try self.createDataRequest(url, .post, params.toJSON())
    }
    
    public func update(_ collection: String, _ params: UpdateParams) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/collection/\(collection)"
        return try self.createDataRequest(url, .patch, params.toJSON())
    }

    public func delete(_ collection: String, _ params: DeleteParams) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/collection/\(collection)"
        return try self.createDataRequest(url, .delete, params.toJSON())
    }
    
    public func count(_ collection: String, _ params: CountParams) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/collection/\(collection)?op=count"
        return try self.createDataRequest(url, .post, params.toJSON())
    }

    public func find(_ collection: String, _ filter: String, _ skip: String, _ limit: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/\(collection)?filter=\(filter)&skip=\(skip)&limit=\(limit)"
        return try self.createDataRequest(url, .get, nil)
    }
    
    public func query(_ params: QueryParams) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/vault/db/query"
        return try self.createDataRequest(url, .post, params.toJSON())
    }
}

public class ConnectionManager {
//    private var _serviceEndpoint: ServiceEndpoint
//    public var hiveApi: HiveAPi
    public var accessionToken: String?
    public var tokenResolver: TokenResolver?
    public let lock: NSLock = NSLock()
    public let baseURL: String
    
    public init(_ baseURL: String) {
        self.baseURL = baseURL
    }

//    init(_ serviceEndpoint: ServiceEndpoint) {
//        self._serviceEndpoint = serviceEndpoint
////        self.hiveApi = HiveAPi(self._serviceEndpoint.providerAddress)
//    }
//
    func headersStream() throws -> HTTPHeaders {
        self.lock.lock()
        let token = try self.tokenResolver!.getToken()!.canonicalizedAccessToken
        self.lock.unlock()
        self.accessionToken = token
        return ["Content-Type": "application/octet-stream", "Authorization": "\(token)", "Transfer-Encoding": "chunked", "Connection": "Keep-Alive"]
    }
//
    func headers() throws -> HTTPHeaders {
        self.lock.lock()
        let token = try self.tokenResolver!.getToken()!.canonicalizedAccessToken
        self.lock.unlock()
        self.accessionToken = token
        return ["Content-Type": "application/json;charset=UTF-8", "Authorization": "\(token)"]
    }
    
    func defaultHeaders() -> HTTPHeaders {
        return ["Content-Type": "application/json;charset=UTF-8"]
    }

//    public static func request(url: URLConvertible,
//                               method: HTTPMethod = .get,
//                               parameters: Parameters? = nil,
//                               headers: HTTPHeaders? = nil) -> DataRequest {
//
//        Log.d("Hive Debug ==> request url ->", url as Any)
//        Log.d("Hive Debug ==> request parameters ->", parameters as Any)
//        Log.d("Hive Debug ==> request headers ->", headers as Any)
//
//        let req: DataRequest = AF.request(url,
//                                          method: method,
//                                          parameters: parameters,
//                                          encoding: JSONEncoding.default,
//                                          headers: headers) { $0.timeoutInterval = HiveAPi.defaultTimeout }
//        return req
//    }
    
    public func createDataRequest(_ url: String,  _ method: HTTPMethod, _ parameters: Dictionary<String, Any>?) throws -> DataRequest {
        return AF.request(url,
                          method: method,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers:nil) { $0.timeoutInterval = HiveAPi.defaultTimeout }
    }
}
