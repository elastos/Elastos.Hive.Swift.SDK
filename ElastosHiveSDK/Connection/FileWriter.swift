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


public class FileWriter: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, StreamDelegate {
    var uploadBoundStreams: BoundStreams
    var task: URLSessionTask? = nil
    let BUFFER_SIZE = 32768
    typealias RequestBlock = (_ error: HiveError) -> Void
    typealias HandleBlock = (_ success: Bool, _ error: HiveError?) -> Void
    private var writerBlock : RequestBlock?
    private var writerCompleteWithError: HandleBlock?
    var uploadDidFinsish: Bool = false
    let _connectionManager: ConnectionManager?
    var _resolver: Resolver<Bool>?
    private var hiveError: HiveError?
    public var cid: String?
    private var cipher: DIDCipher?

    init(_ uploadURL: URL, _ connectionManager: ConnectionManager, cipher: DIDCipher? = nil) {
        self._connectionManager = connectionManager

        var input: InputStream? = nil
        var output: OutputStream? = nil
        self.cipher = cipher

        Stream.getBoundStreams(withBufferSize: BUFFER_SIZE,
                               inputStream: &input,
                               outputStream: &output)

        uploadBoundStreams = BoundStreams(input: input!, output: output!)

        super.init()

        uploadBoundStreams.output.delegate = self
        uploadBoundStreams.output.schedule(in: .current, forMode: .default)
        uploadBoundStreams.output.open()

        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let operationQueue = OperationQueue() // Run in a background queue to not block the main operations (main thread)
        let session = URLSession(configuration: config, delegate: self, delegateQueue: operationQueue)
        var request = try! URLRequest(url: uploadURL, method: .put, headers: self._connectionManager!.headersStream())
        request.addValue("chunked", forHTTPHeaderField: "Transfer-Encoding")
        task = session.uploadTask(withStreamedRequest: request)
        Log.d("Hive Debug ==> request url ->", request.url as Any)
        Log.d("Hive Debug ==> request headers ->", request.allHTTPHeaderFields as Any)

        self.task?.resume()
    }
    
    public func write(data: Data) throws -> Promise<Bool> {
        return DispatchQueue.global().async(.promise){ [self] in
            var edata = data
            if self.cipher != nil {
                let dataBytes = try EncryptionFile(self.cipher!, data).encrypt() as? [UInt8]
                edata = Data(bytes: dataBytes!, count: dataBytes!.count)
                let eed = [UInt8](edata)
                print(eed)
            }
           
            let dataSize = edata.count
            var totalBytesWritten = 0
            var availableRetries = 5
            while totalBytesWritten < dataSize {
                
                let remainingBytesToWrite = dataSize - totalBytesWritten

                // Keep reading the input buffer at the position we haven't read yet (advanced by).
                let bytesWritten = edata.advanced(by: totalBytesWritten).withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) -> Int in

                    return self.uploadBoundStreams.output.write(buffer, maxLength: min(edata.count, remainingBytesToWrite))
                }

                if bytesWritten == -1 {
                    // Something wrong happened - wait a moment - TODO: retry, and throw an exception in case of error several times
                    if availableRetries == 0 {
                        throw HiveError.NetworkException("Failed to write data after several attempts")
                    }

                    availableRetries = availableRetries - 1
                    Thread.sleep(forTimeInterval: 1.0)
                }
                else {
                    totalBytesWritten = totalBytesWritten + bytesWritten
                }
                
                if self.hiveError != nil {
                    throw self.hiveError!
                }
            }
            
            var _result: Bool = false
            self.close {(result, error) in
                if error != nil {
                    self.hiveError = error
                } else {
                    _result = result
                }
            }
            
            if hiveError != nil {
                throw hiveError!
            }
            
            // while until upload success or false
            while self.uploadDidFinsish == false {
                
            }
            return _result
        }
    }
    
    public func write(data: Data, _ error: @escaping (_ error: HiveError) -> Void) throws {
        self.writerBlock = error
        var edata = data
        if self.cipher != nil {
            let dataBytes = try EncryptionFile(self.cipher!, data).encrypt() as? [UInt8]
            edata = Data(bytes: dataBytes!, count: dataBytes!.count)
        }
        
        let dataSize = edata.count
        var totalBytesWritten = 0
        var availableRetries = 5
        while totalBytesWritten < dataSize {
            let remainingBytesToWrite = dataSize - totalBytesWritten

            // Keep reading the input buffer at the position we haven't read yet (advanced by).
            let bytesWritten = edata.advanced(by: totalBytesWritten).withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) -> Int in

                return self.uploadBoundStreams.output.write(buffer, maxLength: min(edata.count, remainingBytesToWrite))
            }

            if bytesWritten == -1 {
                // Something wrong happened - wait a moment - TODO: retry, and throw an exception in case of error several times
                if availableRetries == 0 {
                    throw HiveError.NetworkException("Failed to write data after several attempts")
                }

                availableRetries = availableRetries - 1
                Thread.sleep(forTimeInterval: 1.0)
            }
            else {
                totalBytesWritten = totalBytesWritten + bytesWritten
            }
        }
    }
    
    public func flush() {
        // TODO: maybe on ios nothing to do here.
    }
    
    public func close(_ didCompleteWithError: @escaping (_ success: Bool, _ error: HiveError?) -> Void) {
        self.writerCompleteWithError = didCompleteWithError
        if uploadDidFinsish {
            self.writerCompleteWithError?(true, nil)
        }
        uploadBoundStreams.output.close()
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let response = dataTask.response as? HTTPURLResponse
        Log.d("Hive Debug ==> response Code ->", response?.statusCode as Any)
        Log.d("Hive Debug ==> response body ->", response as Any)
        let code = response?.statusCode
        let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: String]
        if json != nil {
            cid = json!!["cid"]
        }
        
        guard 200...299 ~= code! else {
            
            var error: HiveError? = nil
            switch code {
            case ConnectionManager.BAD_REQUEST:
                error = HiveError.InvalidParameterException("\(error.debugDescription)")
            case ConnectionManager.UNAUTHORIZED:
                error = HiveError.UnauthorizedException("\(error.debugDescription)")
            case ConnectionManager.FORBIDDEN:
                error = HiveError.VaultForbiddenException("\(error.debugDescription)")
            case ConnectionManager.NOT_FOUND:
                error = HiveError.NotFoundException("\(error.debugDescription)")
            case ConnectionManager.ALREADY_EXISTS:
                error = HiveError.AlreadyExistsException("\(error.debugDescription)")
            case ConnectionManager.INSUFFICIENT_STORAGE:
                error = HiveError.InsufficientStorageException("\(error.debugDescription)")
            default: break
            }
            
            if error == nil {
                error = HiveError.NetworkException(String(data: data, encoding: .utf8))
            }
            
            self.hiveError = error
            
            self.writerBlock?(self.hiveError!)
            self.writerCompleteWithError?(false, self.hiveError!)
            return
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        // Provides the input stream to the back end API request. This input stream is filled by our output stream when we write data into it.
        completionHandler(uploadBoundStreams.input)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let response = task.response as? HTTPURLResponse
        Log.d("Hive Debug ==> response Code ->", response?.statusCode as Any)
        Log.d("Hive Debug ==> response body ->", response as Any)

        let code = response?.statusCode
        guard 200...299 ~= code! else {
            
            var error: HiveError? = nil
            switch code {
            case ConnectionManager.BAD_REQUEST:
                error = HiveError.InvalidParameterException("\(error.debugDescription)")
            case ConnectionManager.UNAUTHORIZED:
                error = HiveError.UnauthorizedException("\(error.debugDescription)")
            case ConnectionManager.FORBIDDEN:
                error = HiveError.VaultForbiddenException("\(error.debugDescription)")
            case ConnectionManager.NOT_FOUND:
                error = HiveError.NotFoundException("\(error.debugDescription)")
            case ConnectionManager.ALREADY_EXISTS:
                error = HiveError.AlreadyExistsException("\(error.debugDescription)")
            case ConnectionManager.INSUFFICIENT_STORAGE:
                error = HiveError.InsufficientStorageException("\(error.debugDescription)")
            default: break
            }
            
            if error == nil {
                error = HiveError.NetworkException("\(error!)")
            }
            
            self.hiveError = error
            
            self.writerBlock?(self.hiveError!)
            self.writerCompleteWithError?(false, self.hiveError!)
            return
        }
        
        self.writerCompleteWithError?(true, nil)
        self.uploadDidFinsish = true
        Log.d("Hive Debug ==> upload success", "")
    }
}
