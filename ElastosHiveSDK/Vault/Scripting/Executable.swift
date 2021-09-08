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
import ObjectMapper

/// Represents the executable of the script.
public class Executable: Condition {
    private var _output: Bool?
    
    public init(_ name: String?, _ type: ExecutableType?, _ body: Any?) {
        super.init(name, type?.rawValue, body)
    }
    
    public func setOutput(_ output: Bool) -> Executable {
        self._output = output
        return self
    }
    
    public static func createRunFileParams(_ path: String) -> Dictionary<String, String> {
        return ["path" : path]
    }
    
    required public init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
    }
}
