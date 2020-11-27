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
    private var requestBlock : RequestBlock?
    
    init(url: URL, authHelper: VaultAuthHelper) {
        var input: InputStream? = nil
        var output: OutputStream? = nil
        
        Stream.getBoundStreams(withBufferSize: BUFFER_SIZE,
                               inputStream: &input,
                               outputStream: &output)
        
        uploadBoundStreams = BoundStreams(input: input!, output: output!)

        super.init()
        
        // Get out output stream ready for writing data we willreceive from clients
        uploadBoundStreams.output.delegate = self
        uploadBoundStreams.output.schedule(in: .current, forMode: .default)
        uploadBoundStreams.output.open()
        
        // Start the upload task. This task will wait for input stream data
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let operationQueue = OperationQueue() // Run in a background queue to not block the main operations (main thread)
        let session = URLSession(configuration: config, delegate: self, delegateQueue: operationQueue)
        var request = try! URLRequest(url: url, method: .post, headers: Header(authHelper).headersStream())
        request.addValue("chunked", forHTTPHeaderField: "Transfer-Encoding")
        task = session.uploadTask(withStreamedRequest: request)
        
        self.task?.resume()
    }
    
    public func write(data: Data, _ error: @escaping (_ error: HiveError) -> Void) throws {
        self.requestBlock = error
        let dataSize = data.count
        var totalBytesWritten = 0
        var availableRetries = 5
        while totalBytesWritten < dataSize {
            
            let remainingBytesToWrite = dataSize - totalBytesWritten

            // Keep reading the input buffer at the position we haven't read yet (advanced by).
            let bytesWritten = data.advanced(by: totalBytesWritten).withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) -> Int in

                return self.uploadBoundStreams.output.write(buffer, maxLength: min(dataSize, remainingBytesToWrite))
            }

            if bytesWritten == -1 {
                // Something wrong happened - wait a moment - TODO: retry, and throw an exception in case of error several times
                if availableRetries == 0 {
                    throw HiveError.failure(des: "Failed to write data after several attempts")
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
    
    public func close() {
        uploadBoundStreams.output.close()
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // "{\"_status\":\"OK\"}\n"
        let response = dataTask.response as? HTTPURLResponse
        let code = response?.statusCode
        guard code != nil else {
            self.requestBlock?(HiveError.failure(des: "unknow error."))
            return
        }
        guard 200...299 ~= code! else {
            self.requestBlock?(HiveError.failure(des: String(data: data, encoding: .utf8)))
            return
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        // Provides the input stream to the back end API request. This input stream is filled by our output stream when we write data into it.
        completionHandler(uploadBoundStreams.input)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard error != nil else {
            self.requestBlock?(HiveError.netWork(des: error))
            return
        }
    }
}
