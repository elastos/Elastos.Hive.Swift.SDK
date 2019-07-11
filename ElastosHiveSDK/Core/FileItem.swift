import Foundation
import PromiseKit

protocol FileItem {
    func moveTo(newPath: String) -> HivePromise<Void>
    func moveTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void>

    func copyTo(newPath: String) -> HivePromise<Void>
    func copyTo(newPath: String, handleBy: HiveCallback<Void>) -> HivePromise<Void>

    func deleteItem() -> HivePromise<Void>
    func deleteItem(handleBy: HiveCallback<Void>) -> HivePromise<Void>

    func close()
}

extension FileItem {

    public func readData(_ length: Int) -> HivePromise<Data>{
        return readData(length, handleBy: HiveCallback<Data>())
    }
    public func readData(_ length: Int, handleBy: HiveCallback<Data>) -> HivePromise<Data>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Data>(error: error)
    }

    public func readData(_ length: Int, _ position: UInt64) -> HivePromise<Data>{
        return readData(length, position, handleBy: HiveCallback<Data>())
    }
    public func readData(_ length: Int, _ position: UInt64, handleBy: HiveCallback<Data>) -> HivePromise<Data>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Data>(error: error)
    }

    public func writeData(withData: Data) -> HivePromise<Int32>{
        return writeData(withData: withData, handleBy: HiveCallback<Int32>())
    }
    public func writeData(withData: Data, handleBy: HiveCallback<Int32>) -> HivePromise<Int32>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Int32>(error: error)
    }
    public func writeData(withData: Data, _ position: UInt64) -> HivePromise<Int32>{
        return writeData(withData: withData, position, handleBy: HiveCallback<Int32>())
    }
    public func writeData(withData: Data, _ position: UInt64, handleBy: HiveCallback<Int32>) -> HivePromise<Int32>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Int32>(error: error)
    }

    public func commitData() -> HivePromise<Void>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Void>(error: error)
    }

    public func discardData(){}
}
