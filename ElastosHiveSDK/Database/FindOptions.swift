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
    private var _collation: Collation?

    public override init() { }

    public func projection(_ value: [String: Any]) -> FindOptions {
        return setObjectOption("projection", value)
    }

    public var projection: [String: Any]? {
        return getObjectOption("projection")
    }

    public func skip(_ value: Int) -> FindOptions {
        return setNumberOption("skip", value)
    }

    public var skip: Int? {
        return getNumberOption("skip")
    }

    public func limit(_ value: Int) -> FindOptions {
        return setNumberOption("limit", value)
    }

    public var limit: Int? {
        return getNumberOption("limit")
    }

    public func noCursorTimeout(_ value: Bool) -> FindOptions {
        return setBooleanOption("no_cursor_timeout", value)
    }

    public var noCursorTimeout: Bool? {
        return getBooleanOption("no_cursor_timeout")
    }

    public func sort(_ value: VaultIndex) -> FindOptions {
        _sort.append(value)
        return self
    }

    public func sort(_ value: Array<VaultIndex>) -> FindOptions {
        _sort += value
        return self
    }

    public var sort: Array<VaultIndex>? {
        return _sort
    }

    public func allowPartialResults(_ value: Bool) -> FindOptions {
        return setBooleanOption("allow_partial_results", value)
    }

    public var allowPartialResults: Bool? {
        return getBooleanOption("allow_partial_results")
    }

    public func batchSize(_ value: Int) -> FindOptions {
        return setNumberOption("batch_size", value)
    }

    public var batchSize: Int? {
        return getNumberOption("batch_size")
    }

    public func collation(_ value: Collation) throws -> FindOptions {
        return setObjectOption("collation", try value.jsonSerialize())
    }

    public var collation: Collation? {
        return _collation
    }

    public func returnKey(_ value: Bool) -> FindOptions {
        return setBooleanOption("return_key", value)
    }

    public var returnKey: Bool? {
        return getBooleanOption("return_key")
    }

    public func hint(_ value: VaultIndex) -> FindOptions {
        _hint.append(value)
        return self
    }

    public func hint(_ value: Array<VaultIndex>) -> FindOptions {
        _hint += value
        return self
    }

    public var hint: Array<VaultIndex>? {
        return _hint
    }

    public func maxTimeMS(_ value: Int) -> FindOptions {
        return setNumberOption("max_time_ms", value)
    }

    public var maxTimeMS: Int? {
        return getNumberOption("max_time_ms")
    }

    public func min(_ value: Int) -> FindOptions {
        return setNumberOption("min", value)
    }

    public var min: Int? {
        return getNumberOption("min")
    }

    public func max(_ value: Int) -> FindOptions {
        return setNumberOption("max", value)
    }

    public var max: Int? {
        return getNumberOption("max")
    }

    public func comment(_ value: String) -> FindOptions {
        return setStringOption("comment", value)
    }

    public var comment: String? {
        return getStringOption("comment")
    }

    public func allowDiskUse(_ value: Bool) -> FindOptions {
        return setBooleanOption("allow_disk_use", value)
    }

    public var allowDiskUse: Bool? {
        return getBooleanOption("allow_disk_use")
    }

    public class func deserialize(_ content: String) throws -> FindOptions {
        let data = content.data(using: String.Encoding.utf8)
        let paramars = try JSONSerialization.jsonObject(with: data!,
                                                        options: .mutableContainers) as? [String : Any] ?? [: ]
        let opt = FindOptions()
        opt.param = paramars
        let paramJson = JSON(paramars)
        let hints = paramJson["hint"].arrayValue
        if hints.count != 0 {
            var hs: Array<VaultIndex> = [ ]
            hints.forEach { json in
                json.forEach { k, v in
                    let index = VaultIndex(k, VaultIndex.Order(rawValue: v.intValue)!)
                    hs.append(index)
                }
            }
            opt._hint = hs
        }
        let sort = paramJson["sort"].arrayValue
        if sort.count != 0 {
            var ss: Array<VaultIndex> = [ ]
            hints.forEach { json in
                json.forEach { k, v in
                    let index = VaultIndex(k, VaultIndex.Order(rawValue: v.intValue)!)
                    ss.append(index)
                }
            }
            opt._sort = ss
        }
        if let collation = paramJson["collation"].dictionaryObject {
            opt._collation = Collation.deserialize(collation)
        }
        return opt
    }
}
