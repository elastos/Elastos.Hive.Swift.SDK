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

public class AggregatedCondition: Condition {
    private var conditions: [Condition] = []

    public init(_ type: String, _ name: String, _ conditions: [Condition]) {
        self.conditions = conditions
        super.init(type, name)

    }

    public override init(_ type: String, _ name: String) {
        super.init(type, name)
    }

    public func append(_ condition: Condition) -> AggregatedCondition {
        conditions.append(condition)
        return self
    }

    func body() -> [Condition] {
        return conditions
    }

    override func serialize() throws -> String {
        let jsonGenerator = JsonGenerator()
        jsonGenerator.writeStartObject()
        jsonGenerator.writeStringField("type", type)
        if let _ = name {
            jsonGenerator.writeStringField("name", name!)
        }
        if conditions.count != 0 {
            jsonGenerator.writeFieldName("body")
            jsonGenerator.writeStartArray()
            conditions.forEach { c in
                jsonGenerator.writeStartObject()
                jsonGenerator.writeStringField("type", c.type)
                if let _ = c.name {
                    jsonGenerator.writeStringField("name", c.name!)
                }
                jsonGenerator.writeEndObject()
            }
            jsonGenerator.writeEndArray()
        }
        jsonGenerator.writeEndObject()
        return jsonGenerator.toString()
    }

    public override func jsonSerialize() throws -> [String : Any] {
        var param: [String: Any] = ["type": type]
        if let _ = name {
            param["name"] = name
        }
        if conditions.count > 0 {
            var array: [[String: Any]] = []
            conditions.forEach { c in
                var d = ["type": c.type]
                if let _  = c.name {
                    d["name"] = c.name!
                }
                array.append(d)
            }
            param["body"] = array
        }
        return param
    }
}
