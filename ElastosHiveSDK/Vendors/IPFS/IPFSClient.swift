import Foundation

class IPFSClientHandle: HiveClientHandle, IPFSProtocol {
    private let ipfsRpc: IPFSRpc
    init(_ options: HiveClientOptions) {
        ipfsRpc = IPFSRpc((options as! IPFSClientOptions).rpcNodes)
    }

    public override func connect() throws {
        _ = ipfsRpc.connectAsync()
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
        HivePromise<Hash>{ resolver in
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
        HivePromise<Hash>{ resolver in
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
        HivePromise<Hash>{ resolver in
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

    func putDataFromInputStream(_ input: InputStream) -> Promise<Hash> {
        return putDataFromInputStream(input, handler: HiveCallback<Hash>())
    }

    func putDataFromInputStream(_ input: InputStream, handler: HiveCallback<Hash>) -> Promise<Hash> {
        // TODO:
        return HivePromise<Hash>(error: HiveError.failue(des: "Not implemented"))
    }

    public func sizeofRemoteFile(_ cid: String) -> HivePromise<UInt64> {
        return sizeofRemoteFile(cid, handler: HiveCallback<UInt64>())
    }

    public func sizeofRemoteFile(_ cid: String, handler: HiveCallback<UInt64>) -> HivePromise<UInt64> {
        HivePromise<UInt64>{ resolver in
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
            ipfsRpc.checkValid().then { _ -> HivePromise<Void> in
                return self.doGetDataToTargetFile(cid, targetFile)
            }.done { _ in
                handler.didSucceed(Void())
                resolver.fulfill(Void())
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    func getDataToOutputStream(fromRemoteFile cid: Hash, output: OutputStream) -> Promise<Void> {
        return getDataToOutputStream(fromRemoteFile: cid, output: output, handler: HiveCallback<Void>())
    }

    func getDataToOutputStream(fromRemoteFile: Hash, output: OutputStream, handler: HiveCallback<Void>) -> Promise<Void> {
        // TODO:
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
    }

    
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
        HivePromise<UInt64>{ resolver in
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
}
