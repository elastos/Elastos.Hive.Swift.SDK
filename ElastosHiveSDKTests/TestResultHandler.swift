
import Foundation
@testable import ElastosHiveSDK

class TestResultHandler<T>: HiveCallback<T> {

    init(_ succeed :@escaping ((_ result: T) -> Void),_ error:@escaping ((_ error: HiveError) -> Void)) {
        self.succeedClosure = succeed
        self.errorClosure = error
    }

    open var succeedClosure:((_ result: T) -> Void)

    open var errorClosure:((_ error: HiveError) -> Void)

    public override func didSucceed(_ result: T) -> Void {
        succeedClosure(result)
    }

    public override func runError(_ error: HiveError) -> Void {
        errorClosure(error)
    }

}
