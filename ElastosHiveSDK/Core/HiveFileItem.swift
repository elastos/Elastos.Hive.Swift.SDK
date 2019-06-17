import Foundation
import PromiseKit

protocol HiveFileItem {

    func moveTo(newPath: String) -> HivePromise<Bool>
    func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool>

    func copyTo(newPath: String) -> HivePromise<Bool>
    func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool>

    func deleteItem() -> HivePromise<Bool>
    func deleteItem(handleBy: HiveCallback<Bool>) -> HivePromise<Bool>

    func readData() -> HivePromise<String>
    func readData(handleBy: HiveCallback<String>) -> HivePromise<String>

    func writeData(withData: Data) -> HivePromise<Bool>
    func writeData(withData: Data, handleBy: HiveCallback<Bool>) -> HivePromise<Bool>

    func writeDataWithLarge(withPath: String) -> HivePromise<Bool>
    func writeDataWithLarge(withPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool>

    func close()
}

extension HiveFileItem {

    public func readData() -> HivePromise<String> {
        return readData(handleBy: HiveCallback<String>())
    }

    public func readData(handleBy: HiveCallback<String>) -> HivePromise<String> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<String>(error: error)
    }

    public func writeData(withData: Data) -> HivePromise<Bool> {
        return writeData(withData: withData, handleBy: HiveCallback<Bool>())
    }
    
    public func writeData(withData: Data, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    public func writeDataWithLarge(withPath: String) -> HivePromise<Bool> {
        return writeDataWithLarge(withPath: withPath, handleBy: HiveCallback<Bool>())
    }

    public func writeDataWithLarge(withPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }
}
