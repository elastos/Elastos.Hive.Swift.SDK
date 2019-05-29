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
    
    func close()
}
