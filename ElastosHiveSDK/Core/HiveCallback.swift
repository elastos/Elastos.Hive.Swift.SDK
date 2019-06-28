import Foundation

public class HiveCallback<T> {
    public func didSucceed(_ result: T) -> Void {}
    public func runError(_ error: HiveError) -> Void {}
}
