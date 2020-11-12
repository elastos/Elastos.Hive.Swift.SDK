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

public class CountOptions: Options<CountOptions> {

    public init(_ cSkip: Int, _ cLimit: Int) {
        super.init()
        _ = skip(cSkip)
        _ = limit(cLimit)
    }

    public override init() {

    }

    public func skip(_ value: Int) -> CountOptions {
        return setNumberOption("skip", value)
    }

    public func limit(_ value: Int) -> CountOptions {
        return setNumberOption("limit", value)
    }

    public func maxTimeMS(_ value: Int) -> CountOptions {
        return setNumberOption("maxTimeMS", value)
    }

    public func collation(_ value: Collation) -> CountOptions {
        return setStringOption("skip", value.description)
    }

    public func hint(_ value: VaultIndex) -> CountOptions {
        return setObjectOption("hint", value)
    }

    public func hint(_ value: Array<String>) -> CountOptions {
        return setArrayOption("hint", value)
    }
}
