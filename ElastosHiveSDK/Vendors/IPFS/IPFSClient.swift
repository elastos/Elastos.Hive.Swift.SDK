import Foundation

class IPFSClientHandle: HiveClientHandle, IPFSProtocol {
    private let ipfsRpc: IPFSRpc
    private var fileHandle: FileHandle?
    private var outputStream: OutputStream?
    
    init(_ options: HiveClientOptions) {
        ipfsRpc = IPFSRpc((options as! IPFSClientOptions).rpcNodes)
    }
    
    public override func connect() throws {
        _ = try ipfsRpc.connectAsync().wait()
    }
    
    public override func connectAsync() -> HivePromise<Void> {
        return ipfsRpc.connectAsync()
    }
    
    override func isConnected() -> Bool {
        return ipfsRpc.connectState
    }
    
    public override func disconnect() {
        ipfsRpc.disconnect()
    }
    
    public override func asIPFS() -> IPFSProtocol? {
        return self as IPFSProtocol?
    }
    
    public func putString(_ data: String) -> HivePromise<Hash> {
        return putString(data, handler: HiveCallback<Hash>())
    }
    
    public func putString(_ data: String, handler: HiveCallback<Hash>) -> HivePromise<Hash> {
        return HivePromise<Hash>{ resolver in
            ipfsRpc.checkValid().then { _ -> HivePromise<Hash> in
                return self.doPutString(data)
            }.done { hash in
                handler.didSucceed(hash)
                resolver.fulfill(hash)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func putData(_ data: Data) -> HivePromise<Hash> {
        return putData(data, handler: HiveCallback<Hash>())
    }
    
    public func putData(_ data: Data, handler: HiveCallback<Hash>) -> HivePromise<Hash> {
        return HivePromise<Hash>{ resolver in
            ipfsRpc.checkValid().then { _ -> HivePromise<Hash> in
                return self.doPutData(data)
            }.done { hash in
                handler.didSucceed(hash)
                resolver.fulfill(hash)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func putDataFromFile(_ fileHandle: FileHandle) -> HivePromise<Hash> {
        return putDataFromFile(fileHandle, handler: HiveCallback<Hash>())
    }
    
    public func putDataFromFile(_ fileHandle: FileHandle, handler: HiveCallback<Hash>) -> HivePromise<Hash> {
        return HivePromise<Hash>{ resolver in
            ipfsRpc.checkValid().then { _ -> HivePromise<Hash> in
                return self.doPutDataFromFile(fileHandle)
            }.done { hash in
                handler.didSucceed(hash)
                resolver.fulfill(hash)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func putDataFromInputStream(_ input: InputStream) -> Promise<Hash> {
        return putDataFromInputStream(input, handler: HiveCallback<Hash>())
    }
    
    public func putDataFromInputStream(_ input: InputStream, handler: HiveCallback<Hash>) -> Promise<Hash> {
        return HivePromise<Hash>{ resolver in
            try doPutDataFromInputStream(input).done { hash in
                handler.didSucceed(hash)
                resolver.fulfill(hash)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func sizeofRemoteFile(_ cid: String) -> HivePromise<UInt64> {
        return sizeofRemoteFile(cid, handler: HiveCallback<UInt64>())
    }
    
    public func sizeofRemoteFile(_ cid: String, handler: HiveCallback<UInt64>) -> HivePromise<UInt64> {
        return HivePromise<UInt64>{ resolver in
            ipfsRpc.checkValid().then { _ -> HivePromise<UInt64> in
                return self.doSizeofRemoteFile(cid)
            }.done { size in
                handler.didSucceed(size)
                resolver.fulfill(size)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func getString(fromRemoteFile cid: Hash) -> HivePromise<String> {
        return getString(fromRemoteFile: cid, handler: HiveCallback<String>())
    }
    
    public func getString(fromRemoteFile cid: Hash, handler: HiveCallback<String>) -> HivePromise<String> {
        return HivePromise<String>{ resolver in
            ipfsRpc.checkValid().then { _ -> HivePromise<String> in
                return self.doGetString(cid)
            }.done { str in
                handler.didSucceed(str)
                resolver.fulfill(str)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func getData(fromRemoteFile cid: Hash) -> HivePromise<Data> {
        return getData(fromRemoteFile: cid, handler: HiveCallback<Data>())
    }
    
    public func getData(fromRemoteFile cid: Hash, handler: HiveCallback<Data>) -> HivePromise<Data> {
        return HivePromise<Data>{ resolver in
            ipfsRpc.checkValid().then { _ -> HivePromise<Data> in
                return self.doGetData(cid)
            }.done { data in
                handler.didSucceed(data)
                resolver.fulfill(data)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func getDataToTargetFile(fromRemoteFile cid: Hash, targetFile: FileHandle) -> HivePromise<Void> {
        return getDataToTargetFile(fromRemoteFile: cid, targetFile: targetFile, handler: HiveCallback<Void>())
    }
    
    public func getDataToTargetFile(fromRemoteFile cid: Hash, targetFile: FileHandle, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            self.fileHandle = targetFile
            ipfsRpc.checkValid().then { _ -> HivePromise<Void> in
                return self.doGetDataToTargetFile(cid, self.fileHandle!)
            }.done { _ in
                handler.didSucceed(Void())
                resolver.fulfill(Void())
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func getDataToOutputStream(fromRemoteFile cid: Hash, output: OutputStream) -> HivePromise<Void> {
        return getDataToOutputStream(fromRemoteFile: cid, output: output, handler: HiveCallback<Void>())
    }
    
    public func getDataToOutputStream(fromRemoteFile: Hash, output: OutputStream, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            self.outputStream = output
            ipfsRpc.checkValid().then { _ -> HivePromise<Data> in
                return self.doGetDataToOutputStream(fromRemoteFile: fromRemoteFile, output: output)
            }.done { data in
                self.outputStream?.open()
                self.writeData(data: data, outputStream: self.outputStream!, maxLengthPerWrite: 1024)
                self.outputStream?.close()
                handler.didSucceed(Void())
                resolver.fulfill(Void())
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    //    MARK:- private
    private func doPutString(_ data: String) -> HivePromise<Hash> {
        return doPutData(data.data(using: .utf8)!)
    }
    
    private func doPutData(_ data: Data) -> HivePromise<Hash> {
        let url = IPFSURL.sharedInstance.add()
        return IPFSApis.writeData(url: url, withData: data)
    }
    
    private func doPutDataFromFile(_ fileHandle: FileHandle) -> HivePromise<Hash> {
        fileHandle.seekToEndOfFile()
        return doPutData(fileHandle.readDataToEndOfFile())
    }
    
    private func doSizeofRemoteFile(_ fileName: String) -> HivePromise<UInt64> {
        return HivePromise<UInt64>{ resolver in
            let url = IPFSURL.sharedInstance.ls(fileName)
            IPFSApis.request(url).done { json in
                let json = JSON(json["Objects"][fileName])
                let size = json["Size"].uInt64Value
                resolver.fulfill(size)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    private func doGetString(_ cid: Hash) -> HivePromise<String> {
        return HivePromise<String>{ rsolver in
            let url = IPFSURL.sharedInstance.cat(cid.value)
            IPFSApis.read(url).done { data in
                let jsonStr = String(data: data, encoding: .utf8)
                rsolver.fulfill(jsonStr!)
            }.catch { error in
                rsolver.reject(error)
            }
        }
    }
    
    private func doGetData(_ cid: Hash) -> HivePromise<Data> {
        return HivePromise<Data>{ rsolver in
            let url = IPFSURL.sharedInstance.cat(cid.value)
            IPFSApis.read(url).done { data in
                rsolver.fulfill(data)
            }.catch { error in
                rsolver.reject(error)
            }
        }
    }
    
    private func doGetDataToTargetFile(_ cid: Hash, _ targetFile: FileHandle) -> HivePromise<Void> {
        return HivePromise<Void>{ rsolver in
            let url = IPFSURL.sharedInstance.cat(cid.value)
            IPFSApis.read(url).done { data in
                targetFile.write(data)
                rsolver.fulfill(Void())
            }.catch { error in
                rsolver.reject(error)
            }
        }
    }
    
    private func doPutDataFromInputStream(_ input: InputStream) throws -> HivePromise<Hash> {
        var data = Data()
        input.open()
        
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                //Stream error occured
                throw input.streamError!
            }
            else if read == 0 {
                //EOF
                break
            }
            data.append(buffer, count: read)
        }
        do{
            input.close()
        }
        do{
            buffer.deallocate()
        }
        return doPutData(data)
    }
    
    private func doGetDataToOutputStream(fromRemoteFile: Hash, output: OutputStream) -> HivePromise<Data> {
        return doGetData(fromRemoteFile)
    }
    
    private func writeData(data: Data, outputStream: OutputStream, maxLengthPerWrite: Int) {
        let size = data.count
        data.withUnsafeBytes({(bytes: UnsafePointer<UInt8>) in
            var bytesWritten = 0
            while bytesWritten < size {
                var maxLength = maxLengthPerWrite
                if size - bytesWritten < maxLengthPerWrite {
                    maxLength = size - bytesWritten
                }
                let n = outputStream.write(bytes.advanced(by: bytesWritten), maxLength: maxLength)
                bytesWritten += n
                print(n)
            }
        })
    }
}


