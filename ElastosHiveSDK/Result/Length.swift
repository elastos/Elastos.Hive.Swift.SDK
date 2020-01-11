import Foundation

public class Length: Result {
    private let _length: UInt64

    override init() {
        self._length = 0
        super.init()
    }

    init(_ length: UInt64) {
        self._length = length
    }

    public var length: UInt64 {
        get {
            return self._length
        }
    }
}
