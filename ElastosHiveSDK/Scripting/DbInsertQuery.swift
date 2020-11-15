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

public class DbInsertQuery: Executable {
    private let TYPE = "insert"
    private var query: InsertQuery

    public init(_ name: String, _ collection: String, _ doc: [String: Any]) {
        self.query = InsertQuery(collection, doc)
        super.init(TYPE, name)
    }

    public override func serialize(_ jsonGenerator: JsonGenerator) throws {
        jsonGenerator.writeStartObject()
        jsonGenerator.writeStringField("type", type)
        if let _ = name {
            jsonGenerator.writeStringField("name", name!)
        }
        jsonGenerator.writeFieldName("body")
        try query.serialize(jsonGenerator)
        jsonGenerator.writeEndObject()
    }
}

public class InsertQuery {
    private var collection: String
    private var doc: [String: Any]

    public init(_ collection: String, _ doc: [String: Any]) {
        self.collection = collection
        self.doc = doc
    }
    public func serialize(_ jsonGenerator: JsonGenerator) throws {
        jsonGenerator.writeStartObject()
        jsonGenerator.writeStringField("collection", collection)
        jsonGenerator.writeFieldName("document")
        try serialize(jsonGenerator: jsonGenerator, doc)
        jsonGenerator.writeEndObject()
    }

    private func serialize(jsonGenerator: JsonGenerator, _ param: [String: Any]) throws {
        jsonGenerator.writeStartObject()
        try param.forEach { key, value in
            jsonGenerator.writeFieldName(key)
            if value is Date {
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
            if value is Int {
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

    public func serialize() throws -> String {
        let jsonGenerator = JsonGenerator()

        jsonGenerator.writeStartObject()
        jsonGenerator.writeStringField("collection", collection)
        let data = try JSONSerialization.data(withJSONObject: doc, options: [])
        guard let jsonString = String(data: data, encoding: .utf8) else {
            return ""
        }
        jsonGenerator.writeStringField("document", jsonString)

        return jsonGenerator.toString()
    }

    public func jsonSerialize()throws -> [String: Any] {

        return ["collection": collection, "document": doc]
    }
}

