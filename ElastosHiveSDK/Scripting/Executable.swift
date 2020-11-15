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

public class Executable: NSObject {
    var type: String
    var name: String?
    var output: Bool = false

    init(_ type: String) {
        self.type = type
    }

    init(_ type: String, _ name: String) {
        self.type = type
        self.name = name
    }

    init(_ type: String, _ name: String, _ output: Bool) {
        self.type = type
        self.name = name
        self.output = output
    }

    public func serialize() throws -> String {
        let jsonGenerator = JsonGenerator()
        jsonGenerator.writeStartObject()
        jsonGenerator.writeStringField("type", type)
        if let _ = name {
            jsonGenerator.writeStringField("name", name!)
        }
        jsonGenerator.writeBoolField("output", output)
        jsonGenerator.writeEndObject()
        return jsonGenerator.toString()
    }

    public func serialize(_ jsonGenerator: JsonGenerator) throws {
        jsonGenerator.writeStartObject()
        jsonGenerator.writeStringField("type", type)
        if let _ = name {
            jsonGenerator.writeStringField("name", name!)
        }
        jsonGenerator.writeBoolField("output", output)
        jsonGenerator.writeEndObject()
    }

    public func jsonSerialize()throws -> [String: Any] {
        var para: [String: Any] = ["type": type]
        if let _ = name {
            para["name"] = name
        }
        para["output"] = output
        return para
    }
}

