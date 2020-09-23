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

public class RawCondition: Condition {
    private let TYPE = "raw"
    private var condition: String

    public override init(_ condition: String) {
        self.condition = condition
        super.init(TYPE)
    }

    override func serialize(_ jsonGenerator: JsonGenerator) throws {
        let param = try jsonSerialize()
        try serialize(jsonGenerator: jsonGenerator, param)
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
            if value is Date {
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

    public override func jsonSerialize() throws -> [String: Any] {
        let data = condition.data(using: String.Encoding.utf8)
        let re = try JSONSerialization.jsonObject(with: data!,options: .mutableContainers) as? [String : Any]
        guard re != nil else {
            throw HiveError.IllegalArgument(des: "param is nil")
        }
        return re!
    }

    public override func serialize() -> String {

        return condition
    }
}
