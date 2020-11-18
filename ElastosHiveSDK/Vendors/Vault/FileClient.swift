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

public struct BoundStreams {
    let input: InputStream
    let output: OutputStream
}

public class FileReader: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, StreamDelegate {
    typealias Block = (_ data: Data) -> Void
    var callBack: Block?
    var downloadBoundStreams: BoundStreams
    var task: URLSessionDataTask? = nil
    private var downloadIsEnd: Bool = false

    public var isEnd: Bool {
       if self.downloadBoundStreams.output.streamStatus == Stream.Status.closed {
            return true
        }
        return false
    }
    
    init(url: URL, authHelper: VaultAuthHelper) {
        var input: InputStream? = nil
        var output: OutputStream? = nil
        Stream.getBoundStreams(withBufferSize: 32768,
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
        let request = try! URLRequest(url: url, method: .get, headers: Header(authHelper).headers())
        task = session.dataTask(with: request)
        
        self.task?.resume()
    }
    
    public func read(_ block: @escaping (_ data: Data) -> Void ) {
        callBack = block
    }
    
    public func read() -> Data? {
        
        if self.downloadBoundStreams.input.hasBytesAvailable {
            
            var buffer = [UInt8](repeating: 0, count: 32768)
            self.downloadBoundStreams.input.read(&buffer, maxLength: 32768)
            return Data.init(bytes: buffer)
        }
        return nil
    }
    
    public func flush() {
        // TODO: maybe on ios nothing to do here.
    }
    
    public func close() {
        print("CLOSING OUTPUT STREAM")
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
        
        if callBack != nil {
            callBack!(data)
        }
            
        let dataSize = data.count
        var totalBytesWritten = 0
        while totalBytesWritten < dataSize {
            // Keep reading the input buffer at the position we haven't read yet (advanced by).
            data.advanced(by: totalBytesWritten).withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) -> Void in
                let bytesWritten: Int = self.downloadBoundStreams.output.write(buffer, maxLength: dataSize)
                totalBytesWritten = totalBytesWritten + bytesWritten
            }
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("DID COMPLETE WITH ERROR")
        downloadBoundStreams.output.close()
    }
}

public class FileWriter: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, StreamDelegate {
    
    var uploadBoundStreams: BoundStreams
    var task: URLSessionTask? = nil

    init(url: URL, authHelper: VaultAuthHelper) {
        var input: InputStream? = nil
        var output: OutputStream? = nil
        
        Stream.getBoundStreams(withBufferSize: 32768,
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
        let request = try! URLRequest(url: url, method: .post, headers: Header(authHelper).headers())
        task = session.uploadTask(withStreamedRequest: request)
        
        self.task?.resume()
    }
    
    public func write(data: Data) {
        let dataSize = data.count
        var totalBytesWritten = 0
        while totalBytesWritten < dataSize {
            print("TRYING TO WRITE \(dataSize) BYTES OF DATA")
            
            // Keep reading the input buffer at the position we haven't read yet (advanced by).
            data.advanced(by: totalBytesWritten).withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) -> Void in
                print("SPACE AVAILABLE? \(self.uploadBoundStreams.output.hasSpaceAvailable)")
                
                print("WRITING")
                let bytesWritten: Int = self.uploadBoundStreams.output.write(buffer, maxLength: dataSize)
                totalBytesWritten = totalBytesWritten + bytesWritten
                
                print("WROTE \(bytesWritten) bytes")
            }
        }
        
        print("ALL DATA WRITTEN BY WRITE()")
    }
    
    public func flush() {
        // TODO: maybe on ios nothing to do here.
    }
    
    public func close() {
        print("CLOSING OUTPUT STREAM")
        uploadBoundStreams.output.close()
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        print("NEW BODY NEEDED")
        // Provides the input stream to the back end API request. This input stream is filled by our output stream when we write data into it.
        completionHandler(uploadBoundStreams.input)
    }
    
    /*public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("DID COMPLETE WITH ERROR")
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("DID SEND BODY DATA")
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("DATA DID RECEIVE DATA")
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("DATA DID RECEIVE RESPONSE")
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("INVALID WITH ERROR")
    }*/
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        guard aStream == uploadBoundStreams.output else {
            return
        }
        
        if eventCode.contains(.hasSpaceAvailable) {
            print("HASSPACEAVAILABLE EVENT")
        }
        if eventCode.contains(.errorOccurred) {
            print("ERROROCCURED EVENT")
            // Close the streams and alert the user that the upload failed.
        }
    }
}

public class FileClient: NSObject, FilesProtocol {
    private static let TAG = "FileClient"
    private var authHelper: VaultAuthHelper

    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }

    
    public func upload(_ path: String) -> HivePromise<FileWriter?> {
        return authHelper.checkValid().then { _ -> HivePromise<FileWriter?> in
            return self.uploadImp(path, tryAgain: 0)
        }
    }
    
    var testWriter: FileWriter? = nil // TODO @liaihong: store in a map like in java
    
    private func uploadImp(_ path: String, tryAgain: Int) -> HivePromise<FileWriter?> {
        return HivePromise<FileWriter?> { resolver in
            if let url = URL(string: VaultURL.sharedInstance.upload(path)) {
                testWriter = FileWriter(url: url, authHelper: authHelper)
                resolver.fulfill(testWriter!)
            }
            else {
                resolver.reject(HiveError.failure(des: "Invalid url format"))
            }
        }
    }
    
    var testReader: FileReader? = nil // TODO @liaihong: store in a map like in java

    public func download(_ path: String) -> HivePromise<FileReader> {
        return authHelper.checkValid().then { _ -> HivePromise<FileReader> in
            return self.downloadImp(path, tryAgain: 0)
        }
    }

    private func downloadImp(_ remoteFile: String, tryAgain: Int) -> HivePromise<FileReader> {
        return HivePromise<FileReader> { resolver in
            if let url = URL(string: VaultURL.sharedInstance.download(remoteFile)) {
                testReader = FileReader(url: url, authHelper: authHelper)
                resolver.fulfill(testReader!)
            }
            else {
                resolver.reject(HiveError.failure(des: "Invalid url format"))
            }
        }
    }

//    private func writeData(data: Data, outputStream: OutputStream, maxLengthPerWrite: Int) {
//        let size = data.count
//        data.withUnsafeBytes({(bytes: UnsafePointer<UInt8>) in
//            var bytesWritten = 0
//            while bytesWritten < size {
//                var maxLength = maxLengthPerWrite
//                if size - bytesWritten < maxLengthPerWrite {
//                    maxLength = size - bytesWritten
//                }
//                let n = outputStream.write(bytes.advanced(by: bytesWritten), maxLength: maxLength)
//                bytesWritten += n
//                print(n)
//            }
//        })
//    }

    public func delete(_ path: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.deleteImp(path, tryAgain: 0)
        }
    }

    private func deleteImp(_ remoteFile: String, tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            let param = ["path": remoteFile]
            let url = VaultURL.sharedInstance.deleteFileOrFolder()
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<Bool> in
                            return self.deleteImp(remoteFile, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(FileClient.TAG, "delete ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    resolver.fulfill(true)
                }
            }.catch { error in
                Log.e(FileClient.TAG, "delete ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func move(_ src: String, _ dest: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.moveImp(src, dest, tryAgain: 0)
        }
    }

    private func moveImp(_ src: String, _ dest: String, tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            let url = VaultURL.sharedInstance.move()
            let param = ["src_path": src, "dst_path": dest]
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<Bool> in
                            return self.moveImp(src, dest, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(FileClient.TAG, "move ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    resolver.fulfill(true)
                }
            }.catch { error in
                Log.e(FileClient.TAG, "move ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func copy(_ src: String, _ dest: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.copyImp(src, dest, tryAgain: 0)
        }
    }

    private func copyImp(_ src: String, _ dest: String, tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            let url = VaultURL.sharedInstance.move()
            let param = ["src_path": src, "dst_path": dest]
            VaultApi.request(url: url, parameters: param, headers: Header(authHelper).headers()).done { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<Bool> in
                            return self.copyImp(src, dest, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(FileClient.TAG, "copy ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    resolver.fulfill(true)
                }
            }.catch { error in
                Log.e(FileClient.TAG, "copy ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func hash(_ path: String) -> HivePromise<String> {
        return authHelper.checkValid().then { _ -> HivePromise<String> in
            return self.hashImp(path, tryAgain: 0)
        }
    }

    public func hash(_ path: String, handler: HiveCallback<String>) -> HivePromise<String> {
        return authHelper.checkValid().then { _ -> HivePromise<String> in
            return self.hashImp(path, tryAgain: 0)
        }
    }

    private func hashImp(_ path: String, tryAgain: Int) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            let url = VaultURL.sharedInstance.hash(path)
            VaultApi.request(url: url, method: .get, headers: Header(authHelper).headers()).done { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<String> in
                            return self.hashImp(path, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(FileClient.TAG, "hash ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    resolver.fulfill(json["SHA256"].stringValue)
                }
            }.catch { error in
                Log.e(FileClient.TAG, "hash ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func list(_ path: String) -> HivePromise<Array<FileInfo>> {
        return authHelper.checkValid().then { _ -> HivePromise<Array<FileInfo>> in
            return self.listImp(path, tryAgain: 0)
        }
    }

    private func listImp(_ path: String, tryAgain: Int) -> HivePromise<Array<FileInfo>> {
        return HivePromise<Array<FileInfo>> { resolver in
            let url = VaultURL.sharedInstance.list(path)
            VaultApi.request(url: url, method: .get, headers: Header(authHelper).headers()).done { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<Array<FileInfo>> in
                            return self.listImp(path, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(FileClient.TAG, "list ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    let arraryInfo = json["file_info_list"].arrayValue
                    var fileList = [FileInfo]()
                    arraryInfo.forEach { j in
                        let info = FileInfo()
                        info.setName(j["name"].stringValue)
                        info.setSize(j["size"].intValue)
                        info.setLastModify(j["last_modify"].stringValue)
                        info.setType(j["type"].stringValue)
                        fileList.append(info)
                    }
                    resolver.fulfill(fileList)
                }
            }.catch { error in
                Log.e(FileClient.TAG, "list ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }

    public func stat(_ path: String) -> HivePromise<FileInfo> {
        return authHelper.checkValid().then { _ -> HivePromise<FileInfo> in
            return self.statImp(path, tryAgain: 0)
        }
    }

    private func statImp(_ path: String, tryAgain: Int) -> HivePromise<FileInfo>{
        return HivePromise<FileInfo> { resolver in
            let url = VaultURL.sharedInstance.stat(path)
            VaultApi.request(url: url, method: .get, headers: Header(authHelper).headers()).done { json in
                if !VaultApi.checkResponseIsError(json) {
                    if VaultApi.checkResponseCanRetryLogin(json, tryAgain: tryAgain) {
                        self.authHelper.retryLogin().then { success -> HivePromise<FileInfo> in
                            return self.statImp(path, tryAgain: 1)
                        }.done { result in
                            resolver.fulfill(result)
                        }.catch { error in
                            resolver.reject(error)
                        }
                    } else {
                        let errorStr = HiveError.praseError(json)
                        Log.e(FileClient.TAG, "stat ERROR: ", errorStr)
                        resolver.reject(HiveError.failure(des: errorStr))
                    }
                }
                else {
                    let info = FileInfo()
                    info.setName(json["name"].stringValue)
                    info.setSize(json["size"].intValue)
                    info.setLastModify(json["last_modify"].stringValue)
                    info.setType(json["type"].stringValue)
                    resolver.fulfill(info)
                }
            }.catch { error in
                Log.e(FileClient.TAG, "stat ERROR: ", HiveError.description(error as! HiveError))
                resolver.reject(error)
            }
        }
    }
}
