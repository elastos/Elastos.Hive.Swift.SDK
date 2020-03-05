import Foundation

public typealias Hash = String

public protocol IPFSProtocol {
    func putString(_ data: String) -> HivePromise<Hash>
    func putString(_ data: String, handler: HiveCallback<Hash>) -> HivePromise<Hash>

    func putData(_ data: Data) -> HivePromise<Hash>
    func putData(_ data: Data, handler: HiveCallback<Hash>) -> HivePromise<Hash>

    func putDataFromFile(_ fileHandle: FileHandle) -> HivePromise<Hash>
    func putDataFromFile(_ fileHandle: FileHandle, handler: HiveCallback<Hash>) -> HivePromise<Hash>

    func putDataFromInputStream(_ input: InputStream) -> HivePromise<Hash>
    func putDataFromInputStream(_ input: InputStream, handler: HiveCallback<Hash>) -> HivePromise<Hash>

    func sizeofRemoteFile(_ fileName: Hash) -> HivePromise<UInt64>
    func sizeofRemoteFile(_ fileName: Hash, handler: HiveCallback<UInt64>) -> HivePromise<UInt64>

    func getString(fromRemoteFile: Hash) -> HivePromise<String>
    func getString(fromRemoteFile: Hash, handler: HiveCallback<String>) -> HivePromise<String>

    func getData(fromRemoteFile: Hash) -> HivePromise<Data>
    func getData(fromRemoteFile: Hash, handler: HiveCallback<Data>) -> HivePromise<Data>

    func getDataToTargetFile(fromRemoteFile: Hash, targetFile: FileHandle) -> HivePromise<Void>
    func getDataToTargetFile(fromRemoteFile: Hash, targetFile: FileHandle, handler: HiveCallback<Void>) -> HivePromise<Void>

    func getDataToOutputStream(fromRemoteFile: Hash, output: OutputStream) -> HivePromise<Void>
    func getDataToOutputStream(fromRemoteFile: Hash, output: OutputStream, handler: HiveCallback<Void>) -> HivePromise<Void>
}
