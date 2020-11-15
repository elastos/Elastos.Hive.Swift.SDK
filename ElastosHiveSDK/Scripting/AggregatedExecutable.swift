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

public class AggregatedExecutable: Executable {
    private let TYPE = "aggregated"
    private var executables: [Executable] = []

    public init(_ name: String, _ executables: [Executable]) {
        self.executables = executables
        super.init(TYPE, name)
    }

    public override init(_ name: String) {
        super.init(TYPE, name)
    }

    public func append(_ executable: Executable) throws -> AggregatedExecutable {
        if executable.isMember(of: AggregatedExecutable.self) {
            let ae: AggregatedExecutable = executable as! AggregatedExecutable
            executables.append(ae)
        }
        else if executable.isMember(of: RawExecutable.self) {
            throw HiveError.unsupportedOperation(des: "Can not handle the RawExecutable")
        }
        else {
            executables.append(executable)
        }
        return self
    }

    func body() -> [Executable] {
        return executables
    }

    public override func serialize() throws -> String {
        let jsonGenerator = JsonGenerator()
        jsonGenerator.writeStartObject()
        jsonGenerator.writeStringField("type", type)
        if let _ = name {
            jsonGenerator.writeStringField("name", name!)
        }
        if executables.count != 0 {
            jsonGenerator.writeFieldName("body")
            jsonGenerator.writeStartArray()
            try executables.forEach { e in
               try e.serialize(jsonGenerator)
            }
            jsonGenerator.writeEndArray()
        }
        jsonGenerator.writeEndObject()
        return jsonGenerator.toString()
    }

    public override func serialize(_ jsonGenerator: JsonGenerator) throws {
        if executables.count != 0 {
            try executables.forEach { e in
               try e.serialize(jsonGenerator)
            }
        }
    }

    public override func jsonSerialize() throws -> [String : Any] {
        let str = try serialize()

        let data = str.data(using: String.Encoding.utf8)
        guard data != nil else {
            return [: ]
        }
        return try (JSONSerialization.jsonObject(with: data!,options: .mutableContainers) as? [String : Any])!
    }
}
