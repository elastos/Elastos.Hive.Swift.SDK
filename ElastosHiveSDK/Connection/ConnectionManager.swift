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
    func execute(options: JSONSerialization.ReadingOptions = .allowFragments) throws -> HiveResponse? {
        let response1 = response(responseSerializer: JSONResponseSerializer(options: options))
        switch response1.result {
        case .success(let re):
            if re is NSNull {
                return HiveResponse([:])
            }
            print("*******response*******\n\(re)*******\n")
            let json = re as! [String : Any]
            //            if response?.statusCode != 200 && response?.statusCode != 201 {
            //                throw HiveError
            //            }
            if json["error"] != nil  {
                let errorObject = JSON(json)
                throw NetworkError.NetworkException(message: "\(errorObject["error"]["message"])")
            }
            
            
//            let result = T(JSON: re as! [String : Any])!
            //            try result.checkResponseVaild()
            return HiveResponse(json)
        case .failure(let error):
            let e = error
            switch e {
            case .responseSerializationFailed(_):
                var des = ""
//                if response1.data != nil {
//                    des = String(data: response1.data!, encoding: .utf8) ?? ""
//                }
//                let err = HiveError.responseSerializationFailed(des: des)
//                throw err
            default: break
            }
            throw error
        }
    }
    
    
    func execute<T: Mappable>(options: JSONSerialization.ReadingOptions = .allowFragments, _ resultType: T.Type) throws -> T {
        let response1 = response(responseSerializer: JSONResponseSerializer(options: options))
        switch response1.result {
        case .success(let re):
            // TODO
            if re is NSNull {
                return T(JSON: [:])!
            }
            print("*******response*******\n\(re)*******\n")
            let json = re as! [String : Any]
            //            if response?.statusCode != 200 && response?.statusCode != 201 {
            //                throw HiveError
            //            }
            if json["error"] != nil  {
                let errorObject = JSON(json)
                throw NetworkError.NetworkException(message: "\(errorObject["error"]["message"])")
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

public class ConnectionManager {
    public var tokenResolver: TokenResolver?
    public let lock: NSLock = NSLock()
    public let baseURL: String
    public var accessToken: AccessToken?
    
    public init(_ baseURL: String) {
        self.baseURL = baseURL
    }
    
    func headersStream() -> HTTPHeaders {
        self.lock.lock()
        let token = self.accessToken?.getCanonicalizedAccessToken()
        self.lock.unlock()
        return ["Content-Type": "application/octet-stream", "Authorization": "\(token!)", "Transfer-Encoding": "chunked", "Connection": "Keep-Alive"]
    }
    
    func headers() -> HTTPHeaders {
        self.lock.lock()
        let token = self.accessToken?.getCanonicalizedAccessToken()
        self.lock.unlock()
        return ["Content-Type": "application/json;charset=UTF-8", "Authorization": "\(token!)"]
    }
    
    func defaultHeaders() -> HTTPHeaders {
        return ["Content-Type": "application/json;charset=UTF-8"]
    }
    
    public func createDataNoAuthRequest(_ url: String,  _ method: HTTPMethod, _ parameters: Dictionary<String, Any>?) throws -> DataRequest {
        print("url = \(url)\nheader = \(self.defaultHeaders())")
        
        return AF.request(url,
                          method: method,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers:self.defaultHeaders()) { $0.timeoutInterval = HiveAPi.defaultTimeout }
    }
    
    public func createDataRequest(_ url: String,  _ method: HTTPMethod, _ parameters: Dictionary<String, Any>?) throws -> DataRequest {
        print("*******\nurl = \(url)\nheader = \(self.headers())\nrequest body = \(parameters ?? [:])\n*******\n")
        return AF.request(url,
                          method: method,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers:self.headers()) { $0.timeoutInterval = HiveAPi.defaultTimeout }
    }
}
