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

public class CreateCollectionOptions: Options<CreateCollectionOptions> {

    public override init() {

    }

    public func writeConcern(_ value: WriteConcern?) -> CreateCollectionOptions {
        if let _ = value {
            _ = setObjectOption("write_concern", value as Any)
        }
        else {
            remove("write_concern")
        }

        return self
    }

    public func readConcern(_ value: ReadConcern?) -> CreateCollectionOptions {
        if let _ = value {
            _ = setStringOption("read_concern", value!.description)
        }
        else {
            remove("read_concern")
        }

        return self
    }

    public func readPreference(_ value: ReadPreference?) -> CreateCollectionOptions {
        if let _ = value {
            _ = setStringOption("read_preference", value!.description)
        }
        else {
            remove("read_preference")
        }

        return self
    }

    public func capped(_ value: Bool) -> CreateCollectionOptions {
        _ = setBooleanOption("capped", value)

        return self
    }

    public func size(_ value: Int) -> CreateCollectionOptions {
        _ = setNumberOption("size", value)

        return self
    }

    public func max(_ value: Int) -> CreateCollectionOptions {
        _ = setNumberOption("max", value)

        return self
    }

    public func collation(_ value: Collation?) -> CreateCollectionOptions {
        if let _ = value {
            _ = setObjectOption("collation", value as Any)
        }
        else {
            remove("collation")
        }

        return self
    }
}
