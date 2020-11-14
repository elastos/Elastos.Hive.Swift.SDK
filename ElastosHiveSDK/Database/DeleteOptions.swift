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

public class DeleteOptions: Options<DeleteOptions> {
    private var _collation: Collation?

    public init(_ dCollation: Collation, _ dHint: VaultIndex) throws {
        super.init()
        _collation = dCollation
        _hint = [dHint]
        _ = try collation(dCollation)
        _ = hint(dHint)
    }

    public init(_ dCollation: Collation, _ dHint: Array<VaultIndex>) throws {
        super.init()
        _collation = dCollation
        _hint = dHint
        _ = try collation(dCollation)
        _ = hint(dHint)
    }

    public override init() { }

    public func collation(_ value: Collation) throws -> DeleteOptions{

        return setObjectOption("collation", try value.jsonSerialize())
    }

    public var collation: Collation? {
        return _collation
    }

    public func hint(_ value: VaultIndex) -> DeleteOptions {
        _hint.append(value)
        return self
    }

    public func hint(_ value: Array<VaultIndex>) -> DeleteOptions{
        _hint += value
        return self
    }

    public class func deserialize(_ content: String) throws -> DeleteOptions {
        let data = content.data(using: String.Encoding.utf8)
        let paramars = try JSONSerialization.jsonObject(with: data!,
                                                        options: .mutableContainers) as? [String : Any] ?? [: ]
        let opt = DeleteOptions();
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
        if let collation = paramJson["collation"].dictionaryObject {
            opt._collation = Collation.deserialize(collation)
        }
        return opt
    }
}
