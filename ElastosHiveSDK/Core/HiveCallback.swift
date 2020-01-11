import Foundation

open class HiveCallback<T> {
    public init() {}

    open func didSucceed(_ result: T) {}
    open func runError(_ error: HiveError) {}
}
