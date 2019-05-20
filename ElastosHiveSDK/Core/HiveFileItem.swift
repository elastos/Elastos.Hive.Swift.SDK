import Foundation
import PromiseKit

protocol HiveFileItem {
    var pathName: String { get }
    var parentPathName: String { get }

    func moveTo(newPath: String) -> Promise<HiveStatus>?
    func moveTo(newPath: String, handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>?

    func copyTo(newPath: String) -> Promise<HiveStatus>?
    func copyTo(newPath: String, handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>?

    func deleteItem() -> Promise<HiveStatus>?
    func deleteItem(handleBy: HiveCallback<HiveStatus>) -> Promise<HiveStatus>?

    func close()
}
