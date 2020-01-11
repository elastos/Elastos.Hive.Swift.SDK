import Foundation

class IPFSClientHandle: HiveClientHandle, IPFSProtocol {
    init(_ options: HiveClientOptions) {
        // TODO
    }

    public override func connect() throws {
    }

    public override func disconnect() {
    }

    public override func asFiles() -> FilesProtocol? {
        return nil
    }

    public override func asIPFS() -> IPFSProtocol? {
        return self as IPFSProtocol?
    }

    public override func asKeyValues() -> KeyValuesProtocol? {
        return nil
    }

    public func putString(_ data: String) -> HivePromise<Hash> {
        return putString(data, handler: HiveCallback<Hash>())
    }

    public func putString(_ data: String, handler: HiveCallback<Hash>) -> HivePromise<Hash> {
        return HivePromise<Hash>(error: HiveError.failue(des: "Not implemented"))
    }

    public func putData(_ data: Data) -> HivePromise<Hash> {
        return putData(data, handler: HiveCallback<Hash>())
    }

    public func putData(_ data: Data, handler: HiveCallback<Hash>) -> HivePromise<Hash> {
        return HivePromise<Hash>(error: HiveError.failue(des: "Not implemented"))
    }

    public func putDataFromFile(_ fileHandle: FileHandle) -> HivePromise<Hash> {
        return putDataFromFile(fileHandle, handler: HiveCallback<Hash>())
    }

    public func putDataFromFile(_ fileHandle: FileHandle, handler: HiveCallback<Hash>) -> HivePromise<Hash> {
        return HivePromise<Hash>(error: HiveError.failue(des: "Not implemented"))
    }

    public func sizeofRemoteFile(_ fileName: String) -> HivePromise<UInt64> {
        return sizeofRemoteFile(fileName, handler: HiveCallback<UInt64>())
    }

    public func sizeofRemoteFile(_ fileName: String, handler: HiveCallback<UInt64>) -> HivePromise<UInt64> {
        return HivePromise<UInt64>(error: HiveError.failue(des: "Not implemented"))
    }

    public func getString(fromRemoteFile: Hash) -> HivePromise<String> {
        return getString(fromRemoteFile: fromRemoteFile, handler: HiveCallback<String>())
    }

    public func getString(fromRemoteFile: Hash, handler: HiveCallback<String>) -> HivePromise<String> {
        return HivePromise<String>(error: HiveError.failue(des: "Not implemented"))
    }

    public func getData(fromRemoteFile: Hash) -> HivePromise<Data> {
        return getData(fromRemoteFile: fromRemoteFile, handler: HiveCallback<Data>())
    }

    public func getData(fromRemoteFile: Hash, handler: HiveCallback<Data>) -> HivePromise<Data> {
        return HivePromise<Data>(error: HiveError.failue(des: "Not implemented"))
    }

    public func getDataToTargetFile(fromRemoteFile: Hash, targetFile: FileHandle) -> HivePromise<Void> {
        return getDataToTargetFile(fromRemoteFile: fromRemoteFile, targetFile: targetFile, handler: HiveCallback<Void>())
    }

    public func getDataToTargetFile(fromRemoteFile: Hash, targetFile: FileHandle, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
    }
}
