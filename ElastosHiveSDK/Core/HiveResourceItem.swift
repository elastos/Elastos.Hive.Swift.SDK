import Foundation
import PromiseKit

public protocol HiveResourceItem {
    associatedtype resourceType
    func lastUpdatedInfo() -> Promise<resourceType>?
    func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> Promise<resourceType>?
}
