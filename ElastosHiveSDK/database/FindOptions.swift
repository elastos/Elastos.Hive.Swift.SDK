/*
 * Copyright (c) 2019 Elastos Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation

public class FindOptions: Options<FindOptions> {

    public override init() {

    }

    public func projection(_ value: [String: Any]) -> FindOptions {
        return setObjectOption("projection", value)
    }

    public func skip(_ value: Int) -> FindOptions {
        return setNumberOption("skip", value)
    }

    public func limit(_ value: Int) -> FindOptions {
        return setNumberOption("limit", value)
    }

    public func noCursorTimeout(_ value: Bool) -> FindOptions {
        return setBooleanOption("no_cursor_timeout", value)
    }

    public func sort(_ value: VaultIndex) -> FindOptions {
        return setObjectOption("sort", value)
    }

    public func sort(_ value: Array<VaultIndex>) -> FindOptions {
        return setArrayOption("sort", value)
    }

    public func allowPartialResults(_ value: Bool) -> FindOptions {
        return setBooleanOption("allow_partial_results", value)
    }

    public func batchSize(_ value: Int) -> FindOptions {
        return setNumberOption("batch_size", value)
    }

    public func collation(_ value: Collation) -> FindOptions {
        return setObjectOption("collation", value)
    }

    public func returnKey(_ value: Bool) -> FindOptions {
        return setBooleanOption("return_key", value)
    }

    public func hint(_ value: VaultIndex) -> FindOptions {
        return setObjectOption("hint", value)
    }

    public func hint(_ value: Array<VaultIndex>) -> FindOptions {
        return setArrayOption("hint", value)
    }

    public func maxTimeMS(_ value: Int) -> FindOptions {
        return setNumberOption("max_time_ms", value)
    }

    public func min(_ value: Int) -> FindOptions {
        return setNumberOption("min", value)
    }

    public func max(_ value: Int) -> FindOptions {
        return setNumberOption("max", value)
    }

    public func comment(_ value: String) -> FindOptions {
        return setStringOption("comment", value)
    }

    public func allowDiskUse(_ value: Bool) -> FindOptions {
        return setBooleanOption("allow_disk_use", value)
    }
}
