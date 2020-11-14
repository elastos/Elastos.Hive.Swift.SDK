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

    private var _writeConcern: WriteConcern?
    private var _readConcern: ReadConcern?
    private var _readPreference: ReadPreference?
    private var _collation: Collation?

    public override init() { }

    public func writeConcern(_ value: WriteConcern?) throws -> CreateCollectionOptions {
        if let _ = value {
            _ = setObjectOption("write_concern", try value!.jsonSerialize())
        }
        else {
            remove("write_concern")
        }

        return self
    }

    public var writeConcern: WriteConcern? {
        return _writeConcern
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

    public var readConcern: ReadConcern? {
        return _readConcern
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

    public var capped: Bool? {
        return getBooleanOption("capped")
    }

    public func size(_ value: Int) -> CreateCollectionOptions {
        _ = setNumberOption("size", value)

        return self
    }

    public var size: Int? {
        return getNumberOption("size")
    }

    public func max(_ value: Int) -> CreateCollectionOptions {
        _ = setNumberOption("max", value)

        return self
    }

    public var max: Int? {
        return getNumberOption("max")
    }

    public func collation(_ value: Collation?) throws -> CreateCollectionOptions {
        if let _ = value {
            _ = setObjectOption("collation", try value!.jsonSerialize())
        }
        else {
            remove("collation")
        }
        _collation = value
        return self
    }

    public var collation: Collation? {
        return _collation
    }

    public class func deserialize(_ content: String) throws -> CreateCollectionOptions {
        let data = content.data(using: String.Encoding.utf8)
        let paramars = try JSONSerialization.jsonObject(with: data!,
                                                        options: .mutableContainers) as? [String : Any] ?? [: ]
        let opt = CreateCollectionOptions();
        opt.param = paramars
        let paramJson = JSON(paramars)
        let collation = paramJson["collation"].dictionaryObject ?? [: ]
        opt._collation = Collation.deserialize(collation)
        var parm = paramJson["read_concern"].stringValue
        if parm != "" {
            opt._readConcern = ReadConcern(rawValue: parm)
        }

        parm = paramJson["readPreference"].stringValue
        if parm != "" {
            opt._readPreference = ReadPreference(rawValue: parm)
        }

        if let w = paramJson["writeConcern"].dictionaryObject {
            let write = WriteConcern()
            write.param = w
            opt._writeConcern = write
        }

        return opt
    }
}
