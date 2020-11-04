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

public class DbDeleteQuery: Executable {
    private let TYPE = "delete"
    private var query: Query

    public init(_ name: String, _ collection: String, _ filter: [String: Any]) {
        self.query = Query(collection, filter)
        super.init(TYPE, name)
    }

    func body() -> Query {
        return query
    }
}

public class Query {
    private var collection: String
    private var filter: [String: Any]
    private var options: [String: Any]?

    public init(_ collection: String, _ query: [String: Any]) {
        self.collection = collection
        self.filter = query
    }

    public init(_ collection: String, _ query: [String: Any], _ options: [String: Any]) {
        self.collection = collection
        self.filter = query
        self.options = options
    }

    public func serialize(_ jsonGenerator: JsonGenerator) throws {
        jsonGenerator.writeStartObject()
        jsonGenerator.writeStringField("collection", collection)
        jsonGenerator.writeFieldName("filter")
        try serialize(jsonGenerator: jsonGenerator, filter)
        if let _ = options {
            jsonGenerator.writeFieldName("options")
            try serialize(jsonGenerator: jsonGenerator, options!)
        }
        jsonGenerator.writeEndObject()
    }

    private func serialize(jsonGenerator: JsonGenerator, _ param: [String: Any]) throws {
        jsonGenerator.writeStartObject()
        try param.forEach { key, value in
            jsonGenerator.writeFieldName(key)
            if value is MinKey {
                let m = value as! MinKey
                m.serialize(jsonGenerator)
            }
            else if value is MaxKey {
                let m = value as! MaxKey
                m.serialize(jsonGenerator)
            }
            else if value is RegularExpression {
                let m = value as! RegularExpression
                m.serialize(jsonGenerator)
            }
            else if value is Timestamp {
                let m = value as! Timestamp
                m.serialize(jsonGenerator)
            }
            else if value is ObjectId {
                let m = value as! ObjectId
                m.serialize(jsonGenerator)
            }
            else if value is Date {
                let m = value as! Date
                jsonGenerator.writeStartObject()
                jsonGenerator.writeFieldName("$data")
                jsonGenerator.writeString(Date.convertToUTCStringFromDate(m))
                jsonGenerator.writeEndObject()
            }
            else if value is Int {
                jsonGenerator.writeNumber(value as! Int)
            }
            else if value is Bool {
                let m = value as! Bool
                jsonGenerator.writeBool(m)
            }
            else if value is [String: Any] {
                try serialize(jsonGenerator: jsonGenerator, value as! [String: Any])
            }
            else if value is String {
                jsonGenerator.writeString(value as! String)
            }
            else if value is [Any] {
                let m = value as! [Any]
                try serialize(jsonGenerator: jsonGenerator, m)
            }
        }
        jsonGenerator.writeEndObject()
    }

    private func serialize(jsonGenerator: JsonGenerator, _ param: [Any]) throws {
        jsonGenerator.writeStartArray()
        try param.forEach { value in
            if value is MinKey {
                let m = value as! MinKey
                m.serialize(jsonGenerator)
            }
            else if value is MaxKey {
                let m = value as! MaxKey
                m.serialize(jsonGenerator)
            }
            else if value is RegularExpression {
                let m = value as! RegularExpression
                m.serialize(jsonGenerator)
            }
            else if value is Timestamp {
                let m = value as! Timestamp
                m.serialize(jsonGenerator)
            }
            else if value is Int {
                jsonGenerator.writeNumber(value as! Int)
            }
            else if value is ObjectId {
                let m = value as! ObjectId
                m.serialize(jsonGenerator)
            }
            else if value is Date {
                let m = value as! Date
                jsonGenerator.writeString(Date.convertToUTCStringFromDate(m))
            }
            else if value is Bool {
                let m = value as! Bool
                jsonGenerator.writeBool(m)
            }
            else if value is [String: Any] {
                try serialize(jsonGenerator: jsonGenerator, value as! [String: Any])
            }
            else if value is String {
                jsonGenerator.writeString(value as! String)
            }
            else if value is [Any] {
                let m = value as! [Any]
                try serialize(jsonGenerator: jsonGenerator, m)
            }
        }
        jsonGenerator.writeEndArray()
    }

    public func jsonSerialize()throws -> [String: Any] {

        return ["collection": collection, "filter": filter]
    }
}
