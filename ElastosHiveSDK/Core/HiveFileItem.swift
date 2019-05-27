import Foundation
import PromiseKit

protocol HiveFileItem {

    func moveTo(newPath: String) -> HivePromise<Bool>?
    func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool>?

    func copyTo(newPath: String) -> HivePromise<Bool>?
    func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool>?

    func deleteItem() -> HivePromise<Bool>?
    func deleteItem(handleBy: HiveCallback<Bool>) -> HivePromise<Bool>?

    func close()
}
