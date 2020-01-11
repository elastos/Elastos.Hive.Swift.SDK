import Foundation

public class Hash: Result {
    private let _value: String

    override init() {
        self._value = ""
        super.init()
    }

    init(_ value: String) {
        self._value = value
    }

    public var value: String {
        get {
            return self._value
        }
    }
}
