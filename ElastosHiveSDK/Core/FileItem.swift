import Foundation
import PromiseKit

protocol FileItem {
    func moveTo(newPath: String) -> HivePromise<HiveVoid>
    func moveTo(newPath: String, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid>

    func copyTo(newPath: String) -> HivePromise<HiveVoid>
    func copyTo(newPath: String, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid>

    func deleteItem() -> HivePromise<HiveVoid>
    func deleteItem(handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid>

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

    public func commitData() -> HivePromise<HiveVoid>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }

    public func discardData(){}
}
