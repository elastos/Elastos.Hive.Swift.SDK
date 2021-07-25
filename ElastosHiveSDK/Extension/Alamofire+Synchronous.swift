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
import Alamofire

extension DataRequest {
    /**
     Wait for the request to finish then return the response value.
     
     - returns: The response.
     */
    public func response() -> AFDataResponse<Data?> {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: AFDataResponse<Data?>!
        
        self.response(queue: DispatchQueue.global(qos: .default)) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter responseSerializer: The response serializer responsible for serializing the request, response,
     and data.
     - returns: The response.
     */
    public func response<T: DataResponseSerializerProtocol>(responseSerializer: T) -> AFDataResponse<T.SerializedObject> {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: AFDataResponse<T.SerializedObject>!
        
        self.response(queue: DispatchQueue.global(qos: .default), responseSerializer: responseSerializer) { response in
            
            result = response
            var httpbody: [String: Any]?
            if let requestBody = result?.request?.httpBody {
                httpbody = try! JSONSerialization.jsonObject(with: requestBody, options: []) as? [String: Any]
            }
            
            Log.d("Hive Debug ==> request url ->", response.request?.url as Any)
            Log.d("Hive Debug ==> request headers ->", result.request?.allHTTPHeaderFields as Any)
            Log.d("Hive Debug ==> request httpBody ->", httpbody as Any)
            Log.d("Hive Debug ==> response Code ->", result.response?.statusCode.description as Any)
            Log.d("Hive Debug ==> response body ->", result.result)
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - returns: The response.
     */
    public func responseData() -> AFDataResponse<Data> {
        return response(responseSerializer: DataResponseSerializer())
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter options: The JSON serialization reading options. `.AllowFragments` by default.
     
     - returns: The response.
     */
    public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> AFDataResponse<Any> {
        return response(responseSerializer: JSONResponseSerializer(options: options))
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter encoding: The string encoding. If `nil`, the string encoding will be determined from the
     server response, falling back to the default HTTP default character set,
     ISO-8859-1.
     
     - returns: The response.
     */
    public func responseString(encoding: String.Encoding? = nil) -> AFDataResponse<String> {
        return response(responseSerializer: StringResponseSerializer(encoding: encoding))
    }
}


extension DownloadRequest {
    /**
     Wait for the request to finish then return the response value.
     
     - returns: The response.
     */
    public func response() -> AFDownloadResponse<URL?> {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: AFDownloadResponse<URL?>!
        
        self.response(queue: DispatchQueue.global(qos: .default)) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter responseSerializer: The response serializer responsible for serializing the request, response,
     and data.
     - returns: The response.
     */
    public func response<T: DownloadResponseSerializerProtocol>(responseSerializer: T) -> AFDownloadResponse<T.SerializedObject> {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: AFDownloadResponse<T.SerializedObject>!
        
        self.response(queue: DispatchQueue.global(qos: .background), responseSerializer: responseSerializer) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - returns: The response.
     */
    public func responseData() -> AFDownloadResponse<Data> {
        return response(responseSerializer: DataResponseSerializer())
    }
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter options: The JSON serialization reading options. `.AllowFragments` by default.
     
     - returns: The response.
     */
    public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> AFDownloadResponse<Any> {
        return response(responseSerializer: JSONResponseSerializer(options: options))
    }
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter encoding: The string encoding. If `nil`, the string encoding will be determined from the
     server response, falling back to the default HTTP default character set,
     ISO-8859-1.
     
     - returns: The response.
     */
    public func responseString(encoding: String.Encoding? = nil) -> AFDownloadResponse<String> {
        return response(responseSerializer: StringResponseSerializer(encoding: encoding))
    }
}
