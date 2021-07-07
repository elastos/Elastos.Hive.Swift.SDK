/*
* Copyright (c) 2020 Elastos Foundation
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

public class HiveAPi {
    private var _header: HTTPHeaders?
    private var _url: String?
    private var _parameters: Dictionary<String, Any>?
    private var _httpMethod: HTTPMethod?
    private var _req: DataRequest?
    
    public var baseURL: String
    public static let defaultTimeout: TimeInterval = 30.0
    public var apiPath: String {
        get {
            return "/api/v1"
        }
    }

    public init(_ baseURL: String) {
        self.baseURL = baseURL
    }
    
    public static func request(url: URLConvertible,
                               method: HTTPMethod = .get,
                               parameters: Parameters? = nil,
                               headers: HTTPHeaders? = nil) -> DataRequest {

        Log.d("Hive Debug ==> request url ->", url as Any)
        Log.d("Hive Debug ==> request parameters ->", parameters as Any)
        Log.d("Hive Debug ==> request headers ->", headers as Any)

        let req: DataRequest = AF.request(url,
                                          method: method,
                                          parameters: parameters,
                                          encoding: JSONEncoding.default,
                                          headers: headers) { $0.timeoutInterval = HiveAPi.defaultTimeout }
        return req
    }
    
//    public func createOrder(_ params: CreateOrderParams?) -> HiveAPi {
//        _parameters = params?.toJSON()
//        _httpMethod = .put
//        return self
//    }

    public func execute() -> HiveAPi {
        _req = AF.request(_url!,
                          method: _httpMethod!,
                          parameters: _parameters,
                          encoding: JSONEncoding.default,
                          headers: _header) { $0.timeoutInterval = HiveAPi.defaultTimeout }
        return self
    }
    
    public func body<T: Mappable & HiveCheckValidProtocol>(_ bodyType: T.Type) throws -> T? {
        return try _req!.get(bodyType)
    }
    
//    public func deleteCollection(_ name: String) -> Promise<Bool> {
//        return Promise<Any>.async().then{ [self] _ -> Promise<Bool> in
//            return Promise<Bool> { resolver in
//                let url = self._connectionManager.hiveApi.deleteCollection()
//                let header = try self._connectionManager.headers()
//                let params = DeleteCollectionRequestParams(name)
//                _ = try HiveAPi.request(url: url, method: .post, parameters: params.toJSON(), headers: header).get(HiveResponse.self)
//                resolver.fulfill(true)
//            }
//        }
//    }
    
//    @PUT("/api/v2/vault/db/collections/{collection}")
//        Call<CreateCollectionResult> createCollection(@Path("collection") String collection);
    
}

extension String {
    public func percentEncodingString() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

