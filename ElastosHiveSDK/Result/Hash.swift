import Foundation

public class Hash {
    private let _value: String

    init(_ value: String) {
        self._value = value
    }

    public var value: String {
        get {
            return self._value
        }
    }
}
