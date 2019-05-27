import Foundation
import PromiseKit

public protocol HiveResourceItem {
    associatedtype resourceType
    func lastUpdatedInfo() -> HivePromise<resourceType>?
    func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType>?
}
