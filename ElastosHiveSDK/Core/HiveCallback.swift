import Foundation

public class HiveCallback<T> : GenericCallback {
    public typealias resultType = T

    public func didSucceed(_ result: T) -> Void {
    }

    public func runError(_ error: HiveError) -> Void {
    }
}
