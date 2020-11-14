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

public class UpdateOptions: Options<UpdateOptions> {

    private var _collation: Collation?

    public func upsert(value: Bool) -> UpdateOptions {

        return setBooleanOption("upsert", value)
    }

    public var upsert: Bool? {
        return getBooleanOption("upsert")
    }

    public func bypassDocumentValidation(value: Bool) -> UpdateOptions {

        return setBooleanOption("bypass_document_validation", value)
    }

    public var bypassDocumentValidation: Bool? {
        return getBooleanOption("bypass_document_validation")
    }

    public func collation(value: Collation) throws -> UpdateOptions {

        return setObjectOption("collation", try value.jsonSerialize())
    }

    public var collation: Collation? {
        return _collation
    }

    public func hint(value: VaultIndex) -> UpdateOptions {
        _hint.append(value)
        return self
    }

    public func hint(value: Array<VaultIndex>) -> UpdateOptions {
        _hint += value
        return self
    }

    public var hint: [VaultIndex]? {
        return _hint
    }

    public class func deserialize(_ content: String) throws -> UpdateOptions {
        let data = content.data(using: String.Encoding.utf8)
        let paramars = try JSONSerialization.jsonObject(with: data!,
                                                        options: .mutableContainers) as? [String : Any] ?? [: ]
        let opt = UpdateOptions()
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
