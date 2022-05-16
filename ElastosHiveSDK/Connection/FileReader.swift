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

struct BoundStreams {
    public let input: InputStream
    public let output: OutputStream
}

public class FileReader: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, StreamDelegate {
    var downloadBoundStreams: BoundStreams
    var task: URLSessionDataTask? = nil
    let BUFFER_SIZE = 32768
    
    var allBytesCount: Int = 0
    var totalBytesReadCount: Int = 0
    var downloadDidFinsish: Bool = false
    var readDidFinish: Bool = false
    var resolver: Resolver<FileReader>?
    typealias RequestBlock = (_ error: HiveError) -> Void
    typealias HandleBlock = (_ success: Bool, _ error: HiveError?) -> Void
    var authFailure : RequestBlock?
    private var readerBlock : RequestBlock?
    private var readerCompleteWithError: HandleBlock?
    private var connectionManager: ConnectionManager?
    private var _resolver: Resolver<Bool>?
    
    /// this is for IpfsRunner
    init(_ url: URL, _ method: HTTPMethod) throws {
        var input: InputStream? = nil
        var output: OutputStream? = nil
        Stream.getBoundStreams(withBufferSize: BUFFER_SIZE,
                               inputStream: &input,
                               outputStream: &output)

        downloadBoundStreams = BoundStreams(input: input!, output: output!)
        super.init()

        downloadBoundStreams.output.delegate = self
        downloadBoundStreams.output.schedule(in: .current, forMode: .default)
        downloadBoundStreams.output.open()

        downloadBoundStreams.input.delegate = self
        downloadBoundStreams.input.schedule(in: .current, forMode: .default)
        downloadBoundStreams.input.open()

        let config = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let header = ["Content-Type": "application/json;charset=UTF-8"] as HTTPHeaders
        let session = URLSession(configuration: config, delegate: self, delegateQueue: operationQueue)
        let request = try! URLRequest(url: url, method: method, headers: header)
        
        task = session.dataTask(with: request)
        Log.d("Hive Debug ==> request url ->", request.url as Any)
        Log.d("Hive Debug ==> request headers ->", request.allHTTPHeaderFields as Any)

        self.task?.resume()
    }
    
    public init(_ url: URL,_ connectionManager: ConnectionManager,_ method: HTTPMethod) throws {
        var input: InputStream? = nil
        var output: OutputStream? = nil
        self.connectionManager = connectionManager;
        Stream.getBoundStreams(withBufferSize: BUFFER_SIZE,
                               inputStream: &input,
                               outputStream: &output)

        downloadBoundStreams = BoundStreams(input: input!, output: output!)
        super.init()

        downloadBoundStreams.output.delegate = self
        downloadBoundStreams.output.schedule(in: .current, forMode: .default)
        downloadBoundStreams.output.open()

        downloadBoundStreams.input.delegate = self
        downloadBoundStreams.input.schedule(in: .current, forMode: .default)
        downloadBoundStreams.input.open()

        let config = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let session = URLSession(configuration: config, delegate: self, delegateQueue: operationQueue)
        let request = try! URLRequest(url: url, method: method, headers: self.connectionManager?.headersStream())
        
        task = session.dataTask(with: request)
        Log.d("Hive Debug ==> request url ->", request.url as Any)
        Log.d("Hive Debug ==> request headers ->", request.allHTTPHeaderFields as Any)

        self.task?.resume()
    }
    
    public func read(_ targetUrl: URL) -> Promise<Bool> {
        return DispatchQueue.global().async(.promise){ [self] in
            var hiveError: HiveError? = nil
            while !self.didLoadFinish {
                if let data = self.read({ [self] error in
                    hiveError = error
                }) {
                    if let fileHandle = try? FileHandle(forWritingTo: targetUrl) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    } else {
                        
                    }
                }
                if hiveError != nil {
                    throw hiveError!
                }
            }
            
            var _result: Bool = false
            self.close {(result, error) in
                if error != nil {
                    hiveError = error
                } else {
                    _result = result
                }
            }
            
            if hiveError != nil {
                throw hiveError!
            }
            return _result
        }
    }

    public func read(_ error: @escaping (_ error: HiveError) -> Void) -> Data? {
        return read(BUFFER_SIZE, error)
    }
    
    public func read(_ size: Int, _ error: @escaping (_ error: HiveError) -> Void) -> Data? {
        self.readerBlock = error
        if self.downloadBoundStreams.input.hasBytesAvailable == true {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
            let readBytesCount = self.downloadBoundStreams.input.read(buffer, maxLength: size)
            if readBytesCount == 0 && self.downloadDidFinsish == true {
                self.readDidFinish = true
                return nil
            }
            let data = Data.init(bytes: buffer, count: readBytesCount)
            self.totalBytesReadCount = self.totalBytesReadCount + data.count
            return data
        }
        return nil
    }

    public var didLoadFinish: Bool {
        
        return self.downloadDidFinsish && self.readDidFinish
    }
    
    public func flush() {
        // TODO: maybe on ios nothing to do here.
    }
    
    public func close(_ didCompleteWithError: @escaping (_ success: Bool, _ error: HiveError?) -> Void) {
        self.readerCompleteWithError = didCompleteWithError
        if didLoadFinish {
            self.readerCompleteWithError?(true, nil)
        }
        downloadBoundStreams.input.close()
    }
    
    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    {
        let disposition: URLSession.ResponseDisposition = .allow
        completionHandler(disposition)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let response = dataTask.response as? HTTPURLResponse
        Log.d("Hive Debug ==> didReceive ->", response.debugDescription )
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
                error = HiveError.NetworkException(String(data: data, encoding: .utf8))
            }
            
            
            self.readerBlock?(error!)
            self.readerCompleteWithError?(false, error!)
            self.task?.cancel()
            return
        }
        self.allBytesCount = self.allBytesCount + data.count
        let dataSize = data.count
        var totalBytesWritten = 0
        
        while totalBytesWritten < dataSize {
            
            if self.downloadBoundStreams.output.hasSpaceAvailable {
                data.advanced(by: totalBytesWritten).withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) -> Void in
                    
                    var leaveBytesCount = dataSize - totalBytesWritten
                    leaveBytesCount = leaveBytesCount < BUFFER_SIZE ? leaveBytesCount : BUFFER_SIZE
                    let bytesWritten: Int = self.downloadBoundStreams.output.write(buffer, maxLength: leaveBytesCount)
                    totalBytesWritten = totalBytesWritten + bytesWritten
                }
            }
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let response = task.response as? HTTPURLResponse
        Log.d("Hive Debug ==> response Code ->", response?.statusCode as Any)
        Log.d("Hive Debug ==> didCompleteWithError ->", response as Any)
        
        let code = response?.statusCode
        guard code != nil else {
            self.readerCompleteWithError?(false, HiveError.NetworkException("unkonw error."))
            return
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
                error = HiveError.NetworkException("unknow error")
            }
            
            
            self.readerBlock?(error!)
            self.readerCompleteWithError?(false, error!)
            self.task?.cancel()
            return
        }
        
        if let _ = error {
            self.readerBlock?(HiveError.NetworkException("\(error)"))
            self.readerCompleteWithError?(false, HiveError.NetworkException("\(error)"))
            return
        }
        
        self.downloadDidFinsish = true
        downloadBoundStreams.output.close()
        self.readerCompleteWithError?(true, nil)
        Log.d("Hive Debug ==> reader close.", "")
    }
}
