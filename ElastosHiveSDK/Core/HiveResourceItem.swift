import Foundation
import PromiseKit

public protocol HiveResourceItem {
    associatedtype resourceType

    var handleId: String?       { get }
    var lastInfo: resourceType? { get set }

    func lastUpdatedInfo() -> Promise<resourceType>?
    func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> Promise<resourceType>?
}
