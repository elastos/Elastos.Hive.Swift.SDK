import Foundation

public protocol FilesProtocol {
    func putString(_ data: String, asRemoteFile: String) -> HivePromise<Void>
    func putString(_ data: String, asRemoteFile: String, handler: HiveCallback<Void>) -> HivePromise<Void>

    func putData(_ data: Data, asRemoteFile: String) -> HivePromise<Void>
    func putData(_ data: Data, asRemoteFile: String, handler: HiveCallback<Void>) -> HivePromise<Void>

    func putDataFromFile(_ fileHandle: FileHandle, asRemoteFile: String) -> HivePromise<Void>
    func putDataFromFile(_ fileHandle: FileHandle, asRemoteFile: String, handler: HiveCallback<Void>) -> HivePromise<Void>

    func sizeofRemoteFile(_ fileName: String) -> HivePromise<UInt64>
    func sizeofRemoteFile(_ fileName: String, handler: HiveCallback<UInt64>) -> HivePromise<UInt64>

    func getString(fromRemoteFile: String) -> HivePromise<String>
    func getString(fromRemoteFile: String, handler: HiveCallback<String>) -> HivePromise<String>

    func getData(fromRemoteFile: String) -> HivePromise<Data>
    func getData(fromRemoteFile: String, handler: HiveCallback<Data>) -> HivePromise<Data>

    func getDataToTargetFile(fromRemoteFile: String, targetFile: FileHandle) -> HivePromise<Void>
    func getDataToTargetFile(fromRemoteFile: String, targetFile: FileHandle, handler: HiveCallback<Void>) -> HivePromise<Void>

    func deleteRemoteFile(_ fileName: String) -> HivePromise<Void>
    func deleteRemoteFile(_ fileName: String, handler: HiveCallback<Void>) -> HivePromise<Void>

    // TODO: List
}
