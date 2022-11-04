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
import SwiftyJSON

extension DataRequest {
    func execute(options: JSONSerialization.ReadingOptions = .allowFragments) throws -> HiveResponse? {
        let response1 = response(responseSerializer: JSONResponseSerializer(options: options))
        let code = response1.response?.statusCode
        switch code {
        case ConnectionManager.BAD_REQUEST:
            throw HiveError.InvalidParameterException("\(error.debugDescription)")
        case ConnectionManager.UNAUTHORIZED:
            throw HiveError.UnauthorizedException("\(error.debugDescription)")
        case ConnectionManager.FORBIDDEN:
            throw HiveError.VaultForbiddenException("\(error.debugDescription)")
        case ConnectionManager.NOT_FOUND:
            throw HiveError.NotFoundException("\(error.debugDescription)")
        case ConnectionManager.ALREADY_EXISTS:
            throw HiveError.AlreadyExistsException("\(error.debugDescription)")
        case ConnectionManager.INSUFFICIENT_STORAGE:
            throw HiveError.InsufficientStorageException("\(error.debugDescription)")
        default: break
        }
        
        if response1.data != nil {
            switch response1.result {
            case .success(let re):
                if re is NSNull {
                    return HiveResponse([:])
                } else if re is [String : Any] {
                    Log.d("Hive Debug", "*******response*******\n\(re)*******\n")
                    let json = re as! [String : Any]
                    if json["error"] != nil  {
                        let errorObject = JSON(json)
                        throw NetworkError.NetworkException(message: "\(errorObject["error"]["message"])")
                    }
                    return HiveResponse(json)
                }
                return nil
            case .failure(let error):
                throw error
            }
        } else {
            return HiveResponse([:])
        }
    }
    
    
    func execute<T: Mappable>(options: JSONSerialization.ReadingOptions = .allowFragments, _ resultType: T.Type) throws -> T {
        let response1 = response(responseSerializer: JSONResponseSerializer(options: options))
        let code = response1.response?.statusCode
        switch code {
        case ConnectionManager.BAD_REQUEST:
            throw HiveError.InvalidParameterException("\(error.debugDescription)")
        case ConnectionManager.UNAUTHORIZED:
            throw HiveError.UnauthorizedException("\(error.debugDescription)")
        case ConnectionManager.FORBIDDEN:
            throw HiveError.VaultForbiddenException("\(error.debugDescription)")
        case ConnectionManager.NOT_FOUND:
            throw HiveError.NotFoundException("\(error.debugDescription)")
        case ConnectionManager.ALREADY_EXISTS:
            throw HiveError.AlreadyExistsException("\(error.debugDescription)")
        case ConnectionManager.INSUFFICIENT_STORAGE:
            throw HiveError.InsufficientStorageException("\(error.debugDescription)")
        default: break
        }
        
        if response1.data != nil {
            switch response1.result {
            case .success(let re):
                if re is NSNull {
                    return T(JSON: [:])!
                } else if re is [String : Any] {
                    Log.d("Hive Debug", "*******response*******\n\(re)*******\n")
                    let json = re as! [String : Any]
                    if json["error"] != nil  {
                        let errorObject = JSON(json)
                        throw NetworkError.NetworkException(message: "\(errorObject["error"]["message"])")
                    }
                    
                    let result = T(JSON: re as! [String : Any])!
                    return result
                }
                throw HiveError.NetworkException("unvalid json response")
            case .failure(let error):
                throw error
            }
        } else {
            return T(JSON: [:])!
        }
        
    }
}

public class ConnectionManager {
    public let lock: NSLock = NSLock()
    public let baseURL: String
    public var accessToken: AccessToken?
    
    public static let BAD_REQUEST: Int = 400
    public static let UNAUTHORIZED: Int = 401
    public static let FORBIDDEN: Int = 403
    public static let NOT_FOUND: Int = 404
    public static let ALREADY_EXISTS: Int = 455
    public static let INSUFFICIENT_STORAGE: Int = 507

    public init(_ baseURL: String) {
        self.baseURL = baseURL
    }
    
    func headersStream() throws -> HTTPHeaders {
        self.lock.lock()
        let aToken = try (accessToken?.fetch() != nil) ? accessToken!.fetch()! : ""
        let token = "token " + aToken

        self.lock.unlock()
        return ["Content-Type": "application/octet-stream", "Authorization": "\(token)", "Transfer-Encoding": "chunked", "Connection": "Keep-Alive"]
    }
    
    func headers() throws -> HTTPHeaders {
        self.lock.lock()
        let aToken = try (accessToken?.fetch() != nil) ? accessToken!.fetch()! : ""
        let token = "token " + aToken

        self.lock.unlock()
        
        var header = self.defaultHeaders()
                header.add(name: "Authorization", value: token)
        return header
    }
    
    func defaultHeaders() -> HTTPHeaders {
        return ["Content-Type": "application/json;charset=UTF-8"]
    }
    
    public func createDataNoAuthRequest(_ url: String,  _ method: HTTPMethod, _ parameters: Dictionary<String, Any>?) throws -> DataRequest {
        return AF.request(url,
                          method: method,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers:self.defaultHeaders()) { $0.timeoutInterval = 30 }
    }
    
    public func createDataRequest(_ url: String,  _ method: HTTPMethod, _ parameters: Dictionary<String, Any>?) throws -> DataRequest {
        print("Debug ==> request parameters -> ", parameters)
        return AF.request(url,
                          method: method,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers:try self.headers()) { $0.timeoutInterval = 30 }
    }
}
