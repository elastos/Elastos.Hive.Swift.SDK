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
    var resolver: Resolver<FileReader>
    typealias AuthFailure = (_ error: HiveError) -> Void
    var authFailure : AuthFailure?
    typealias RequestBlock = (_ error: HiveError) -> Void
    private var requestBlock : RequestBlock?
    typealias BlockRead = (_ block: Bool) -> Void
    private var blockRead : BlockRead?
    
    init(url: URL, authHelper: VaultAuthHelper, resolver: Resolver<FileReader>) {
        var input: InputStream? = nil
        var output: OutputStream? = nil
        self.resolver = resolver
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
        let request = try! URLRequest(url: url, method: .get, headers: Header(authHelper).headersStream())
        task = session.dataTask(with: request)
        
        self.task?.resume()
    }
    
    public func read(_ error: @escaping (_ error: HiveError) -> Void) -> Data? {
        return read(BUFFER_SIZE, error)
    }
    
    public func read(_ size: Int, _ error: @escaping (_ error: HiveError) -> Void) -> Data? {
        self.requestBlock = error
        if self.downloadBoundStreams.input.hasBytesAvailable == true {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
            let readBytesCount = self.downloadBoundStreams.input.read(buffer, maxLength: size)
            if readBytesCount == 0 && self.downloadDidFinsish == true {
                self.readDidFinish = true
                return nil
            }
            let data = Data.init(bytes: buffer, count: readBytesCount)
            print("read \(readBytesCount)")
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
        let response = dataTask.response as? HTTPURLResponse
        let code = response?.statusCode
        guard code != nil else {
            self.resolver.reject(HiveError.failure(des: "unkonw error."))
            return
        }
        if code == 200 {
            resolver.fulfill(self)
        }
        guard 200...299 ~= code! else {
            resolver.reject(HiveError.failure(des: String(data: data, encoding: .utf8)))
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
                    print("totalBytesWritten = \(totalBytesWritten), data count = \(dataSize)")
                    self.blockRead?(true)
                }
            }
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let _ = error {
            self.requestBlock?(HiveError.netWork(des: error))
            return
        }
        let response = task.response as? HTTPURLResponse
        let code = response?.statusCode
        guard code != nil else {
            self.resolver.reject(HiveError.failure(des: "unkonw error."))
            return
        }
        guard 200...299 ~= code! else {
            if code == 401 {
                self.authFailure?(HiveError.failure(des: "code: 401"))
                self.task?.cancel()
                return
            }
            resolver.reject(HiveError.failure(des: "code: \(code)"))
            return
        }
//        print("DID COMPLETE WITH ERROR")
        self.downloadDidFinsish = true
        downloadBoundStreams.output.close()
    }
}

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
            print("TRYING TO WRITE \(dataSize) BYTES OF DATA")
            
            let remainingBytesToWrite = dataSize - totalBytesWritten

            // Keep reading the input buffer at the position we haven't read yet (advanced by).
            let bytesWritten = data.advanced(by: totalBytesWritten).withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) -> Int in
                //print("SPACE AVAILABLE? \(self.uploadBoundStreams.output.hasSpaceAvailable)")

                print("WRITING")
                return self.uploadBoundStreams.output.write(buffer, maxLength: min(dataSize, remainingBytesToWrite))
            }

            if bytesWritten == -1 {
                // Something wrong happened - wait a moment - TODO: retry, and throw an exception in case of error several times
                if availableRetries == 0 {
                    throw HiveError.failure(des: "Failed to write data after several attempts")
                }

                print("Failed to write data, retrying...")

                availableRetries = availableRetries - 1
                Thread.sleep(forTimeInterval: 1.0)
            }
            else {
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
        print("Upload success.")
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        print("NEW BODY NEEDED")
        // Provides the input stream to the back end API request. This input stream is filled by our output stream when we write data into it.
        completionHandler(uploadBoundStreams.input)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard error != nil else {
            self.requestBlock?(HiveError.netWork(des: error))
            return
        }
        print("DID COMPLETE WITHOUT ERROR")
    }
}

public class FileClient: NSObject, FilesProtocol {
    private static let TAG = "FileClient"
    private var authHelper: VaultAuthHelper
    var writer: FileWriter? = nil
    var reader: FileReader? = nil
    
    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }

    public func upload(_ path: String) -> HivePromise<FileWriter> {
        return authHelper.checkValid().then { _ -> HivePromise<FileWriter> in
            return self.uploadImp(path, tryAgain: 0)
        }
    }
    
    private func uploadImp(_ path: String, tryAgain: Int) -> HivePromise<FileWriter> {
        return HivePromise<FileWriter> { resolver in
            if let url = URL(string: VaultURL.sharedInstance.upload(path)) {
                writer = FileWriter(url: url, authHelper: authHelper)
                resolver.fulfill(writer!)
            }
            else {
                resolver.reject(HiveError.failure(des: "Invalid url format"))
            }
        }
    }
    
    public func download(_ path: String) -> HivePromise<FileReader> {
        return authHelper.checkValid().then { _ -> HivePromise<FileReader> in
            return self.downloadImp(path, tryAgain: 0)
        }
    }

    private func downloadImp(_ remoteFile: String, tryAgain: Int) -> HivePromise<FileReader> {
        return HivePromise<FileReader> { resolver in
            if let url = URL(string: VaultURL.sharedInstance.download(remoteFile)) {
                reader = FileReader(url: url, authHelper: authHelper, resolver: resolver)
                reader?.authFailure = { error in
                    if tryAgain >= 1 {
                        resolver.reject(error)
                        return
                    }
                    self.authHelper.retryLogin().then { success -> HivePromise<FileReader> in
                        return self.downloadImp(remoteFile, tryAgain: 1)
                    }.done { result in
                        resolver.fulfill(result)
                    }.catch { error in
                        resolver.reject(error)
                    }
                }
            }
            else {
                resolver.reject(HiveError.failure(des: "Invalid url format"))
            }
        }
    }

    public func delete(_ path: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.deleteImp(path, 0)
        }
    }

    private func deleteImp(_ remoteFile: String, _ tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            let param = ["path": remoteFile]
            let url = VaultURL.sharedInstance.deleteFileOrFolder()

            let response = Alamofire.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
        
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if tryLogin {
                try self.authHelper.signIn()
                deleteImp(remoteFile, 1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }

    public func move(_ src: String, _ dest: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.moveImp(src, dest, 0)
        }
    }

    private func moveImp(_ src: String, _ dest: String, _ tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            let url = VaultURL.sharedInstance.move()
            let param = ["src_path": src, "dst_path": dest]
            let response = Alamofire.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if tryLogin {
                try self.authHelper.signIn()
                moveImp(src, dest, 1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }

    public func copy(_ src: String, _ dest: String) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.copyImp(src, dest, 0)
        }
    }

    private func copyImp(_ src: String, _ dest: String, _ tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in
            let url = VaultURL.sharedInstance.move()
            let param = ["src_path": src, "dst_path": dest]
            let response = Alamofire.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if tryLogin {
                try self.authHelper.signIn()
                copyImp(src, dest, 1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }

    public func hash(_ path: String) -> HivePromise<String> {
        return authHelper.checkValid().then { _ -> HivePromise<String> in
            return self.hashImp(path, 0)
        }
    }

    private func hashImp(_ path: String, _ tryAgain: Int) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            let url = VaultURL.sharedInstance.hash(path)
            let response = Alamofire.request(url,
                                method: .get,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if tryLogin {
                try self.authHelper.signIn()
                hashImp(path, 1).done { sha256 in
                    resolver.fulfill(sha256)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(json["SHA256"].stringValue)
        }
    }

    public func list(_ path: String) -> HivePromise<Array<FileInfo>> {
        return authHelper.checkValid().then { _ -> HivePromise<Array<FileInfo>> in
            return self.listImp(path, 0)
        }
    }

    private func listImp(_ path: String, _ tryAgain: Int) -> HivePromise<Array<FileInfo>> {
        return HivePromise<Array<FileInfo>> { resolver in
            let url = VaultURL.sharedInstance.list(path)
            let response = Alamofire.request(url,
                                method: .get,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if tryLogin {
                try self.authHelper.signIn()
                listImp(path, 1).done { list in
                    resolver.fulfill(list)
                }.catch { error in
                    resolver.reject(error)
                }
            }
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
    }

    public func stat(_ path: String) -> HivePromise<FileInfo> {
        return authHelper.checkValid().then { _ -> HivePromise<FileInfo> in
            return self.statImp(path, 0)
        }
    }

    private func statImp(_ path: String, _ tryAgain: Int) -> HivePromise<FileInfo>{
        return HivePromise<FileInfo> { resolver in
            let url = VaultURL.sharedInstance.stat(path)
            let response = Alamofire.request(url,
                                method: .get,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let tryLogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if tryLogin {
                try self.authHelper.signIn()
                statImp(path, 1).done { info in
                    resolver.fulfill(info)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            let info = FileInfo()
            info.setName(json["name"].stringValue)
            info.setSize(json["size"].intValue)
            info.setLastModify(json["last_modify"].stringValue)
            info.setType(json["type"].stringValue)
            resolver.fulfill(info)
        }
    }
}
