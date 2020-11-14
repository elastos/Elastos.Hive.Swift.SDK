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

public class VaultIndex: NSObject {
   public enum Order : Int {
        case ASCENDING = 1
        case DESCENDING = -1
    }

    private var _key: String
    private var _order: Order

    public init(_ key: String, _ order: Order) {
        self._key = key
        self._order = order
        super.init()
    }

    public var key: String {
        return _key
    }

    public var order: Order {
        return _order
    }

    public func serialize() throws -> String {
        let jsonGenerator = JsonGenerator()
        jsonGenerator.writeStartObject()
        jsonGenerator.writeNumberField(key, order.rawValue)

        return jsonGenerator.toString()
    }

    public func jsonSerialize()throws -> [String: Any] {

        return [key: _order.rawValue]
    }
}

