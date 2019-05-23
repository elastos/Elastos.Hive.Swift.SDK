import Foundation
import PromiseKit

protocol HiveFileItem {

    func moveTo(newPath: String) -> Promise<HiveStatus>?
    func moveTo(newPath: String, handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>?

    func copyTo(newPath: String) -> Promise<HiveStatus>?
    func copyTo(newPath: String, handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>?

    func deleteItem() -> Promise<HiveStatus>?
    func deleteItem(handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>?

    func close()
}
