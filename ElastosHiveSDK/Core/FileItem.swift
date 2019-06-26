import Foundation
import PromiseKit

protocol FileItem {
    func moveTo(newPath: String) -> HivePromise<Bool>
    func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool>

    func copyTo(newPath: String) -> HivePromise<Bool>
    func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool>

    func deleteItem() -> HivePromise<Bool>
    func deleteItem(handleBy: HiveCallback<Bool>) -> HivePromise<Bool>

    func close()
}

extension FileItem {

    public func readData() -> HivePromise<Data>{
        return readData(handleBy: HiveCallback<Data>())
    }
    public func readData(handleBy: HiveCallback<Data>) -> HivePromise<Data>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Data>(error: error)
    }

    public func readData(_ position: UInt64) -> HivePromise<Data>{
        return readData(position, handleBy: HiveCallback<Data>())
    }
    public func readData(_ position: UInt64, handleBy: HiveCallback<Data>) -> HivePromise<Data>{
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

    public func commitData() -> HivePromise<Bool>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    public func discardData(){}
}
