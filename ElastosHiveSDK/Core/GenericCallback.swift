import Foundation

public protocol GenericCallback {
    associatedtype resultType

    func didSucceed(_ result: resultType) -> Void
    func runError(_ error: HiveError) -> Void
}
