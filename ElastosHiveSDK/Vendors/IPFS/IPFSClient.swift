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
                return self.do_putString(data)
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
                return self.do_putData(data)
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
                return self.do_putDataFromFile(fileHandle)
            }.done { hash in
                handler.didSucceed(hash)
                resolver.fulfill(hash)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    public func sizeofRemoteFile(_ fileName: String) -> HivePromise<UInt64> {
        return sizeofRemoteFile(fileName, handler: HiveCallback<UInt64>())
    }

    public func sizeofRemoteFile(_ fileName: String, handler: HiveCallback<UInt64>) -> HivePromise<UInt64> {
        HivePromise<UInt64>{ resolver in
            ipfsRpc.checkValid().then { _ -> HivePromise<UInt64> in
                return self.do_sizeofRemoteFile(fileName)
            }.done { size in
                handler.didSucceed(size)
                resolver.fulfill(size)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    public func getString(fromRemoteFile: Hash) -> HivePromise<String> {
        return getString(fromRemoteFile: fromRemoteFile, handler: HiveCallback<String>())
    }

    public func getString(fromRemoteFile: Hash, handler: HiveCallback<String>) -> HivePromise<String> {
        return HivePromise<String>{ resolver in
            ipfsRpc.checkValid().then { _ -> HivePromise<String> in
                return self.do_getString(fromRemoteFile: fromRemoteFile)
            }.done { str in
                handler.didSucceed(str)
                resolver.fulfill(str)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    public func getData(fromRemoteFile: Hash) -> HivePromise<Data> {
        return getData(fromRemoteFile: fromRemoteFile, handler: HiveCallback<Data>())
    }

    public func getData(fromRemoteFile: Hash, handler: HiveCallback<Data>) -> HivePromise<Data> {
        return HivePromise<Data>{ resolver in
            ipfsRpc.checkValid().then { _ -> HivePromise<Data> in
                return self.do_getData(fromRemoteFile: fromRemoteFile)
            }.done { data in
                handler.didSucceed(data)
                resolver.fulfill(data)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    public func getDataToTargetFile(fromRemoteFile: Hash, targetFile: FileHandle) -> HivePromise<Void> {
        return getDataToTargetFile(fromRemoteFile: fromRemoteFile, targetFile: targetFile, handler: HiveCallback<Void>())
    }

    public func getDataToTargetFile(fromRemoteFile: Hash, targetFile: FileHandle, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            ipfsRpc.checkValid().then { _ -> HivePromise<Void> in
                return self.do_getDataToTargetFile(fromRemoteFile: fromRemoteFile, targetFile: targetFile)
            }.done { _ in
                handler.didSucceed(Void())
                resolver.fulfill(Void())
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    private func do_putString(_ data: String) -> HivePromise<Hash> {
        return do_putData(data.data(using: .utf8)!)
    }
    
    private func do_putData(_ data: Data) -> HivePromise<Hash> {
        let url = IPFSURL.sharedInstance.add()
        return IPFSApis.writeData(url: url, withData: data)
    }
    
    private func do_putDataFromFile(_ fileHandle: FileHandle) -> HivePromise<Hash> {
        fileHandle.seekToEndOfFile()
        let data = fileHandle.readDataToEndOfFile()
        return do_putData(data)
    }
    
    private func do_sizeofRemoteFile(_ fileName: String) -> HivePromise<UInt64> {
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
    
    private func do_getString(fromRemoteFile: Hash) -> HivePromise<String> {
        return HivePromise<String>{ rsolver in
            let url = IPFSURL.sharedInstance.cat(fromRemoteFile.value)
            IPFSApis.read(url).done { data in
                let jsonStr = String(data: data, encoding: .utf8)
                rsolver.fulfill(jsonStr!)
            }.catch { error in
                rsolver.reject(error)
            }
        }
    }
    
    private func do_getData(fromRemoteFile: Hash) -> HivePromise<Data> {
        return HivePromise<Data>{ rsolver in
            let url = IPFSURL.sharedInstance.cat(fromRemoteFile.value)
            IPFSApis.read(url).done { data in
                rsolver.fulfill(data)
            }.catch { error in
                rsolver.reject(error)
            }
        }
    }
    
    private func do_getDataToTargetFile(fromRemoteFile: Hash, targetFile: FileHandle) -> HivePromise<Void> {
        return HivePromise<Void>{ rsolver in
            let url = IPFSURL.sharedInstance.cat(fromRemoteFile.value)
            IPFSApis.read(url).done { data in
                targetFile.write(data)
                rsolver.fulfill(Void())
            }.catch { error in
                rsolver.reject(error)
            }
        }
    }
}
