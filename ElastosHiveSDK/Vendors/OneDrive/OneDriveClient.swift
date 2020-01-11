import Foundation

class OneDriveClientHandle: HiveClientHandle, FilesProtocol, KeyValuesProtocol {
    init(_ options: HiveClientOptions) {
        // TODO:
    }

    public override func connect() throws {
    }

    public override func disconnect() {
    }

    public override func asFiles() -> FilesProtocol? {
        return self as FilesProtocol
    }

    public override func asKeyValues() -> KeyValuesProtocol? {
        return self as KeyValuesProtocol
    }

    public func putString(_ data: String, asRemoteFile: String) -> HivePromise<Void> {
        putString(data, asRemoteFile: asRemoteFile, handler: HiveCallback<Void>())
    }

    public func putString(_ data: String, asRemoteFile: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
    }

    public func putData(_ data: Data, asRemoteFile: String) -> HivePromise<Void> {
        return putData(data, asRemoteFile: asRemoteFile, handler: HiveCallback<Void>())
    }

    public func putData(_ data: Data, asRemoteFile: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
    }

    public func putDataFromFile(_ fileHandle: FileHandle, asRemoteFile: String) -> HivePromise<Void> {
        return putDataFromFile(fileHandle, asRemoteFile: asRemoteFile, handler: HiveCallback<Void>())
    }

    public func putDataFromFile(_ fileHandle: FileHandle, asRemoteFile: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
    }

    public func sizeofRemoteFile(_ fileName: String) -> HivePromise<UInt64> {
        return sizeofRemoteFile(fileName, handler: HiveCallback<UInt64>())
    }

    public func sizeofRemoteFile(_ fileName: String, handler: HiveCallback<UInt64>) -> HivePromise<UInt64> {
        return HivePromise<UInt64>(error: HiveError.failue(des: "Not implemented"))
    }

    public func getString(fromRemoteFile: String) -> HivePromise<String> {
        return getString(fromRemoteFile: fromRemoteFile, handler: HiveCallback<String>())
    }

    public func getString(fromRemoteFile: String, handler: HiveCallback<String>) -> HivePromise<String> {
        return HivePromise<String>(error: HiveError.failue(des: "Not implemented"))
    }

    public func getData(fromRemoteFile: String) -> HivePromise<Data> {
        return getData(fromRemoteFile: fromRemoteFile, handler: HiveCallback<Data>())
    }

    public func getData(fromRemoteFile: String, handler: HiveCallback<Data>) -> HivePromise<Data> {
        return HivePromise<Data>(error: HiveError.failue(des: "Not implemented"))
    }

    public func getDataToTargetFile(fromRemoteFile: String, targetFile: FileHandle) -> HivePromise<Void> {
        return getDataToTargetFile(fromRemoteFile: fromRemoteFile, targetFile: targetFile, handler: HiveCallback<Void>())
    }

    public func getDataToTargetFile(fromRemoteFile: String, targetFile: FileHandle, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
    }

    public func deleteRemoteFile(_ fileName: String) -> HivePromise<Void> {
        return deleteRemoteFile(fileName, handler: HiveCallback<Void>())
    }

    public func deleteRemoteFile(_ fileName: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
    }

    public func putValue(_ aValue: String, forKey: String) -> HivePromise<Void> {
        return putValue(aValue, forKey: forKey,  handler: HiveCallback<Void>())
    }

    public func putValue(_ aValue: String, forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
    }

    public func putValue(_ aValue: Data, forKey: String) -> HivePromise<Void> {
        return putValue(aValue, forKey: forKey,  handler: HiveCallback<Void>())
    }

    public func putValue(_ aValue: Data, forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
    }

    public func setValue(_ newValue: String, forKey: String) -> HivePromise<Void> {
        return setValue(newValue, forKey: forKey, handler: HiveCallback<Void>())
    }

    public func setValue(_ newValue: String, forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
    }

    public func setValue(_ newValue: Data, forKey: String) -> HivePromise<Void> {
        return setValue(newValue, forKey: forKey, handler:  HiveCallback<Void>())
    }

    public func setValue(_ newValue: Data, forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
    }

    public func values(ofKey: String) -> HivePromise<ValueList> {
        return values(ofKey: ofKey, handler: HiveCallback<ValueList>())
    }

    public func values(ofKey: String, handler: HiveCallback<ValueList>) -> HivePromise<ValueList> {
        return HivePromise<ValueList>(error: HiveError.failue(des: "Not implemented"))
    }

    public func deleteValues(forKey: String) -> HivePromise<Void> {
        return deleteValues(forKey: forKey, handler: HiveCallback<Void>())
    }

    public func deleteValues(forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
    }
}
